class User < ApplicationRecord
    encrypts :google_access_token
    encrypts :google_refresh_token
    has_secure_password
    attr_accessor :role_name
    attr_accessor :role_name_kana
    attr_accessor :reset_token
    validates :email_address, presence: true, uniqueness: true,
              format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :role, presence: true, inclusion: { in: %w[teacher parent admin] }
    validates :password, presence: true, length: { minimum: 8 }, if: :password_digest_changed?
    has_one :teacher, dependent: :destroy
    has_one :family, dependent: :destroy



    def authenticated?(attribute, token)
      digest = send("#{attribute}_digest")
      return false if digest.nil?
      BCrypt::Password.new(digest).is_password?(token)
    end

    def User.new_token
    SecureRandom.urlsafe_base64
    end

    def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
    end
after_create :create_role_record

  # メソッド全体の役割: 新しいトークンを生成し、ハッシュ化してDBに保存する
  def create_reset_digest
  self.reset_token = User.new_token
  # true/falseが返る
  update(
    reset_digest: User.digest(reset_token), # トークンをハッシュ化してDBに保存
    reset_sent_at: Time.zone.now # トークンに有効期限を設定のため
  )
  end
  # UserMailerに「これから使うデータ」を渡す
  def send_password_reset_email
    UserMailer.with(user: self)
    # パスワード再設定用のリンクをつける（user_mailer.rb）
    .password_reset
    .deliver_now
  end
  # ２時間経過しているかどうかをtrue/falseで分岐する
  def password_reset_expired?
    # 2時間経過していればtrue
    reset_sent_at + 2.hours < Time.zone.now
  end




    def refresh_google_token!
    return google_access_token if google_token_expires_at.present? && google_token_expires_at > Time.current

    client = OAuth2::Client.new(
      Rails.application.credentials.google[:client_id],
      Rails.application.credentials.google[:client_secret],
      site: "https://oauth2.googleapis.com"
    )

    token = OAuth2::AccessToken.new(client, google_access_token, refresh_token: google_refresh_token)
    new_token = token.refresh!

    update(
      google_access_token: new_token.token,
      google_token_expires_at: Time.at(new_token.expires_at)
    )

    google_access_token
    end



private
def create_role_record
    if role == "teacher"
        Teacher.create!(user: self)
    elsif role == "parent"
        Family.create!(user: self, name: role_name, name_kana: role_name_kana)
    end
end
end
