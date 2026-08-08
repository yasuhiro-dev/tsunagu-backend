class UserMailer < ApplicationMailer
    def password_reset
    @user = params[:user]
    @token = @user.reset_token
    # 開発環境と本番環境でURL先を分けた
    @url = "#{ENV['FRONTEND_URL']}/password_reset_confirm?token=#{@token}"
    mail(to: @user.email_address, subject: "パスワードの再設定")
    end
end
