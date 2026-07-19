class Api::V1::GoogleAuthController < ApplicationController
    before_action :authenticate_user!, only: [ :connect ]

    def connect
        state = encode_token({ user_id: current_user.id }, expires_in: 5.minutes)

        redirect_to google_client.auth_code.authorize_url(
            redirect_uri: callback_url,
            scope: "https://www.googleapis.com/auth/gmail.send https://www.googleapis.com/auth/calendar.events",
            state: state,
            access_type: "offline",
            prompt: "consent"
        ), allow_other_host: true
    end

    def callback
    payload = decode_token(params[:state])

    if payload.nil?
      return redirect_to "http://localhost:3001/settings?google_connected=false&error=invalid_state"
    end

    user = User.find_by(id: payload["user_id"])

    if user.nil?
      return redirect_to "http://localhost:3001/settings?google_connected=false&error=user_not_found"
    end

    token = google_client.auth_code.get_token(
      params[:code],
      redirect_uri: callback_url
    )
    user.update(
      google_access_token: token.token,
      google_refresh_token: token.refresh_token,
      google_token_expires_at: Time.at(token.expires_at)
    )

    redirect_to "http://localhost:3001/settings?google_connected=true"
  end

   private

  def google_client
    OAuth2::Client.new(
      Rails.application.credentials.google[:client_id],
      Rails.application.credentials.google[:client_secret],
      site: "https://accounts.google.com",
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token"
    )
  end

  def callback_url
    "http://localhost:3000/api/v1/google_auth/callback"
  end
end
