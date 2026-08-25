class Api::V1::GoogleAuthController < ApplicationController
    before_action :authenticate_user!, only: [ :connect, :status ]
    # google認証
    def connect
        # 5分で失効
        state = encode_token({ user_id: current_user.id }, expires_in: 5.minutes)
        # google認証URLの設定
        url = google_client.auth_code.authorize_url(
            # 認証後のURL先
            redirect_uri: callback_url,
            # gmailとgoogleカレンダーを許可する
            scope: "https://www.googleapis.com/auth/gmail.send https://www.googleapis.com/auth/calendar.events",
            state: state,
            # ユーザーがブラウザを閉じていても使用できる（メール送信時）
            access_type: "offline",
            prompt: "consent"
        )
        render json: { url: url }
    end

    # google認証後の処理
    def callback
    payload = decode_token(params[:state]) # 署名付きトークンが返ってくる
    # 認証されなかった場合
    if payload.nil?
      return redirect_to "#{ENV['FRONTEND_URL']}/settings?google_connected=false&error=invalid_state"
    end
    # トークン情報からuserをDBから探す
    user = User.find_by(id: payload["user_id"])
    # userが見つからない場合
    if user.nil?
      return redirect_to "#{ENV['FRONTEND_URL']}/settings?google_connected=false&error=user_not_found"
    end
    # Googleから返ってきた認可コードを取得し、更新する
    token = google_client.auth_code.get_token(
      params[:code],
      redirect_uri: callback_url
    )
    user.update(
      google_access_token: token.token,
      google_refresh_token: token.refresh_token,
      google_token_expires_at: Time.at(token.expires_at)
    )
    redirect_to "#{ENV['FRONTEND_URL']}/settings?google_connected=true"
  end

  # 現在ログイン中のユーザーがトークンを持っているか確認
  def status
    render json: { connected: current_user.google_access_token.present? }, status: :ok
  end

   private

   #  services/google_oauth_clientで管理
   def google_client
    GoogleOauthClient.build
   end

  def callback_url
    "#{ENV['BACKEND_URL']}/api/v1/google_auth/callback"
  end
end
