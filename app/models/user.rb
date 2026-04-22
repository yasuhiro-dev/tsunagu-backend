class User < ApplicationRecord
    has_secure_password
    validates :email_address, presence: true, uniqueness: true
    has_one :teacher

after_create :create_teacher

private
    def create_teacher
        Teacher.create!(user:self)
    end
end
