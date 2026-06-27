class User < ApplicationRecord
    has_secure_password
    attr_accessor :reset_token
    validates :email_address, presence: true, uniqueness: true
    validates :role, presence: true, inclusion: { in: %w[teacher parent admin] }
    has_one :teacher, dependent: :destroy
    has_one :family, dependent: :destroy

    def User.new_token
    SecureRandom.urlsafe_base64
    end

    def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
    end
after_create :create_role_record

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.with(user: self).password_reset.deliver_later
  end

private
def create_role_record
    if role == "teacher"
        Teacher.create!(user: self)
    elsif role == "parent"
        Family.create!(user: self)
    end
end
end
