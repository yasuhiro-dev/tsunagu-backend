class Api::V1::PasswordResetsController < ApplicationController
  def create
    @user = User.find_by(email_address: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      render json: { message: "メールを送信しました" }, status: :ok

    else
      render json: { message: "メール送信に失敗しました" }, status: :not_found
    end
  end

  def update
      @user = User.all.find { |u| u.authenticated?(:reset, params[:token]) }
    if @user
         if params[:user][:password].empty?
           render json: { message: "パスワードの再設定に失敗しました" }, status: :unprocessable_entity
         elsif @user.update(user_params)
           render json: { message: "パスワードを再設定しました" }, status: :ok
         else
           render json: { message: "パスワードの再設定に失敗しました" }, status: :unprocessable_entity
         end

    else
        render json: { message: "トークンの取得に失敗しました" }, status: :not_found
    end
    end
    private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
