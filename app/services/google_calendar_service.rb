class GoogleCalendarService
CALENDER_URL="https://www.googleapis.com/calendar/v3/calendars/primary/events"

  def initialize(user)
    @user = user
  end

  def register_calendar(summary:, start_at:, end_at:)
    ensure_valid_token

    response = access_token.post(
      CALENDER_URL,
      headers: { "Content-Type" => "application/json" },
      body: { summary: summary,
     start: { dateTime: start_at.iso8601, timeZone: "Asia/Tokyo" },
     end: { dateTime: end_at.iso8601, timeZone: "Asia/Tokyo" } }.to_json
    )
    JSON.parse(response.body)
  end

  private

  def ensure_valid_token
    raise "この保護者はGoogle連携が完了していません" unless @user.google_access_token.present?
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
end
