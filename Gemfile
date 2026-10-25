source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.2"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapter for Active Job
gem "solid_queue"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

group :development, :test do
  # デバッグ系
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "pry-byebug"
  gem "pry-doc"
  gem "pry-rails"
  # 品質チェック系
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  # テスト系
  gem "rspec-rails"
  gem "factory_bot_rails"
end

group :development do
  # ER図を書くため
  gem "rails-erd"
end
# デモアカウント生成
gem "faker"
gem "gimei"

gem "jwt"

gem "mysql2"
# google認証
gem "oauth2"
# PDF生成
gem "grover"
