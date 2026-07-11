module Authentication
  extend ActiveSupport::Concern

  SECRET_KEY = Rails.application.credentials.secret_key_base || ENV["SECRET_KEY_BASE"]

  def encode_token(payload)
    payload[:exp] = (Time.now + 30.minutes).to_i
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def decode_token(token)
    JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })[0]
  rescue JWT::DecodeError
    nil
  end

  def current_user
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last
    decoded = decode_token(token)
    @current_user ||= User.find_by(id: decoded["user_id"]) if decoded
  end

  def authenticate_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end

  def authorize_role!(*roles)
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user && roles.include?(current_user.role)
  end
end
