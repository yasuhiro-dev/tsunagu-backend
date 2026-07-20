class GoogleOauthClient
    def self.build
    OAuth2::Client.new(
      Rails.application.credentials.google[:client_id],
      Rails.application.credentials.google[:client_secret],
      site: "https://accounts.google.com",
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token"
    )
  end
end
