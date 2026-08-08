class UserMailer < ApplicationMailer
    def password_reset
    @user = params[:user]
    @token = @user.reset_token
    @url = "https://tsunagu-app.com/password_reset_confirm?token=#{@token}"
    mail(to: @user.email_address, subject: "パスワードの再設定")
    end
end
