class Api::V1::SessionsController < ApplicationController
    def create
        user = User.find_by(email_address: params[:email_address])
        if user &. authenticate(params[:password])
            token = encode_token({ user_id: user.id })
            render json: { token: token, role: user.role }, status: :ok
        else
            render json { error :"Invalid email or password" }, status: :unauthorized
        end
    end
end
