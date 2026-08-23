class GoogleOauthClient
    # googleのトークンを取得メソッド
    def self.build
    OAuth2::Client.new(
      Rails.application.credentials.google[:client_id], # googleにこのアプリを認識させる
      Rails.application.credentials.google[:client_secret], # このアプリの証明書
      site: "https://accounts.google.com", # googleのどのサイトに飛ばすか
      authorize_url: "/o/oauth2/auth", # 同意画面（ユーザーがブラウザで見る）
      token_url: "/o/oauth2/token" # トークン取得（サーバー間通信、ユーザーには見えない）
    )
  end
end
