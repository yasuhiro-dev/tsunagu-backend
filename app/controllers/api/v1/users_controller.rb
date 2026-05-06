class Api::V1::UsersController<ApplicationController
    def create
        ActiveRecord::Base.transaction do
            user=User.create!(user_params)
            family =Family.create!(name: params[:family_name], user: user)
            child = Child.create!(name: params[:child_name], family: family)
            ChildClassRoom.create!(class_room_id: params[:class_room_id], child: child)
        end

        render json: { message: "登録完了" }, status: :created
    rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.message }, status: :unprocessable_entity
    end

    private
    def user_params
        params.require(:user).permit(:email_address, :password, :role)
    end
end
