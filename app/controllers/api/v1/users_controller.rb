class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create_parent ]
  def create_parent
    schedule = Schedule.order(created_at: :desc).first
    ActiveRecord::Base.transaction do
      @user = User.new(parent_params)
      @user.role = "parent"
      @user.role_name = params[:family_name]
      @user.role_name_kana = params[:family_name_kana]

      unless @user.save
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      @family = @user.family
      children_params_list.each do |child_attrs|
        child = Child.new(name: child_attrs[:name], name_kana: child_attrs[:name_kana], family_id: @family.id, schedule_id: schedule&.id)
        unless child.save
          render json: { errors: child.errors.full_messages }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
        child_class_room = ChildClassRoom.new(child_id: child.id, class_room_id: child_attrs[:class_room_id])
        unless child_class_room.save
          render json: { errors: child_class_room.errors.full_messages }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      end
    end

    return if performed?

  render json: {
  token: encode_token({
    user_id: @user.id,
    role: @user.role,
    family_id: @family.id,
    name: @family.name
  }),
  user: {
    id: @user.id,
    email_address: @user.email_address
  }
}, status: :created
end

  private

  def parent_params
    params.require(:user).permit(:email_address, :password)
  end

  def children_params_list
    params.require(:children).map do |child|
      child.permit(:name, :name_kana, :class_room_id)
    end
  end
end
