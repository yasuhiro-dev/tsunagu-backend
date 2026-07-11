FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "test#{n}@example.com" }
    role { "parent" }
    password { "password123" }
    role_name { "テスト保護者" }
  end
end
