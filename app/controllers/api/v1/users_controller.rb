class Api::V1::UsersController < ApplicationController
  def create_parent
    ActiveRecord::Base.transaction do
      # ① 保護者ユーザーを作成
      @user = User.new(parent_params)
      @user.role = "parent"

      unless @user.save
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

     # ② 自動作成されたfamilyを取得して名前を更新
@family = @user.family
@family.update(name: params[:family_name])


      # ③ 児童を複数保存
      children_params_list.each do |child_attrs|
        # 児童を保存
        child = Child.new(name: child_attrs[:name], family_id: @family.id)
        unless child.save
          render json: { errors: child.errors.full_messages }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end

        # child_class_rooms に保存
        child_class_room = ChildClassRoom.new(child_id: child.id, class_room_id: child_attrs[:class_room_id])
        unless child_class_room.save
          render json: { errors: child_class_room.errors.full_messages }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      end
    end

    return if performed?

    render json: {
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
      child.permit(:name, :class_room_id)
    end
  end
end