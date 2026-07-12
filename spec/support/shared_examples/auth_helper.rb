module AuthHelper
  def auth_headers_for(user)
    payload = {
      user_id: user.id,
      role: user.role,
      family_id: user.family&.id,
      name: user.teacher&.name || user.family&.name
    }
    payload[:exp] = (Time.now + 30.minutes).to_i
    token = JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
    { "Authorization" => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end