require "mail"

class GmailService
  GMAIL_SEND_URL = "https://gmail.googleapis.com/gmail/v1/users/me/messages/send"

  def initialize(user)
    @user = user
  end
  #
  def send_email(to:, subject:, body:)
    # トークンがあるか確認する
    ensure_valid_token
    # データ構造を作成
    raw_message = build_raw_message(to: to, subject: subject, body: body)
    # アクセストークンを使ってgmailAPIへリクエストする
    response = access_token.post(
      GMAIL_SEND_URL,
      headers: { "Content-Type" => "application/json" },
      body: { raw: raw_message }.to_json
    )
    # リクエスト受け付けを確認
    JSON.parse(response.body)
  end

  private
  # アクセストークンが存在していなければ、メッセージを送り中断
  def ensure_valid_token
    raise "この教師はGoogle連携が完了していません" unless @user.google_access_token.present?
    # トークンの有効期限がまだなら何もしない
    return if @user.google_token_expires_at > Time.now
    # もし切れているならリフレッシュトークンを渡す
    refresh_access_token
  end
  # リフレッシュトークンを使ってトークンを発行する
  def refresh_access_token
    token = GoogleOauthClient.build.get_token(
      grant_type: "refresh_token",
      refresh_token: @user.google_refresh_token
    )
    @user.update(
      google_access_token: token.token,
      google_token_expires_at: Time.at(token.expires_at)
    )
  end
  # .post呼び出し時に自動でAuthorizationヘッダーを付与
  def access_token
    OAuth2::AccessToken.new(GoogleOauthClient.build, @user.google_access_token)
  end
  # メールのデータ構造を作成
  def build_raw_message(to:, subject:, body:)
    mail = Mail.new do
      to           to
      subject      subject
      body         body
      # メールの本文がテキストで日本語として表示される設定
      content_type "text/plain; charset=UTF-8"
    end
    # JSON経由で壊れずに送るため
    Base64.urlsafe_encode64(mail.to_s)
  end
end
