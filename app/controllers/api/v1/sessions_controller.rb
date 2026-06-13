class Api::V1::SessionsController < ApplicationController
    def create
        user = User.find_by(email_address: params[:email_address])
        if user &.authenticate(params[:password])
            name = user.teacher&.name || user.family&.name
            token = encode_token({ user_id: user.id, role: user.role, family_id: user.family&.id, name: name })
            render json: { token: token, role: user.role }, status: :ok
        else
            render json { error :"Invalid email or password" }, status: :unauthorized
        end
    end
end
