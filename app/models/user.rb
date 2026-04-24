class User < ApplicationRecord
    has_secure_password
    validates :email_address, presence: true, uniqueness: true
    validates :role, presence: true, inclusion: { in: %w[teacher parent] }
    has_one :teacher
    has_one :family

after_create :create_role_record

private
def create_role_record
    if role == "teacher"
        Teacher.create!(user: self)
    else
        Family.create!(user: self)
    end
end
end
