require "mail"

class GmailService
  GMAIL_SEND_URL = "https://gmail.googleapis.com/gmail/v1/users/me/messages/send"

  def initialize(user)
    @user = user
  end

  def send_email(to:, subject:, body:)
    ensure_valid_token

    raw_message = build_raw_message(to: to, subject: subject, body: body)

    response = access_token.post(
      GMAIL_SEND_URL,
      headers: { "Content-Type" => "application/json" },
      body: { raw: raw_message }.to_json
    )
    JSON.parse(response.body)
  end

  private

  def ensure_valid_token
    raise "この教師はGoogle連携が完了していません" unless @user.google_access_token.present?
    return if @user.google_token_expires_at > Time.now
    refresh_access_token
  end

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
  def access_token
    OAuth2::AccessToken.new(GoogleOauthClient.build, @user.google_access_token)
  end
  def build_raw_message(to:, subject:, body:)
    mail = Mail.new do
      to           to
      subject      subject
      body         body
      content_type "text/plain; charset=UTF-8"
    end
    Base64.urlsafe_encode64(mail.to_s)
  end
end
