class Api::V1::PasswordResetsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create, :update ]
  # メソッド全体の役割:リクエストで送られたメールアドレスからUserを特定し、新しいトークンを作成しメールを送信する
  def create
  @user = User.find_by(email_address: params[:password_reset][:email].downcase)
  if @user
    @user.create_reset_digest
    @user.send_password_reset_email
  end
  # ユーザーの有無に関わらず、常に同じレスポンスを返す
  # （メールアドレスの登録有無を外部から判別できないようにするため）
  render json: { message: "登録されているメールアドレスの場合、リセット用のメールを送信しました" }, status: :ok
end

  # メソッド全体の役割:トークンの照合によってユーザーを特定して、パスワードを更新するメソッド
  def update
      # フロントから渡されたトークンと、DBに保存されたreset_digestと一致するUserを見つける
      @user = User.all.find { |u| u.authenticated?(:reset, params[:token]) }
        if @user
          # トークンの有効期限を確認するメソッド
          if @user.password_reset_expired?
            render json: { message: "有効期限切れのためもう一度行ってください" }, status: :unprocessable_entity
          else
            if params[:user][:password].empty?
              render json: { message: "パスワードの再設定に失敗しました" }, status: :unprocessable_entity
            elsif @user.update(user_params)
              render json: { message: "パスワードを再設定しました" }, status: :ok
            else
              # @user.update(user_params) が false を返した場合
              render json: { message: "パスワードの再設定に失敗しました" }, status: :unprocessable_entity
            end
          end
        else
          # Userが見つからない時の処理
          render json: { message: "トークンの取得に失敗しました" }, status: :not_found
        end
  end

    private
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
