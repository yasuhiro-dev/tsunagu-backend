class Api::V1::AdminController < ApplicationController
  before_action -> { authorize_role!("admin") }

  def index
    teachers = User.where(role: "teacher").includes(teacher: { class_rooms: [] })
    parents = User.where(role: "parent").includes(family: { children: :class_rooms })

    render json: {
      teachers: teachers.map { |u|
        {
          id: u.id,
          email_address: u.email_address,
          name: u.teacher&.name,
          name_kana: u.teacher&.name_kana,
          classname: u.teacher&.class_rooms&.map { |class_room| class_room.classname }&.join("・")
        }
      },
      parents: parents.map { |u|
        {
          id: u.id,
          email_address: u.email_address,
          name: u.family&.name,
          name_kana: u.family&.name_kana,
          children_name: u.family&.children&.map(&:name)&.join("、"),
          children_class: u.family&.children&.map { |c| c.class_rooms.map { |r| r.classname }.join("・") }&.join("、")
        }
      }
    }, status: :ok
  end

  def create_teacher
    ActiveRecord::Base.transaction do
      @user = User.new(teacher_params)
      @user.role = "teacher"
      unless @user.save
        render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      @teacher = @user.teacher
      @teacher.update(name: params[:name])

      @class_room = ClassRoom.find(params[:class_room_id])
      @class_room.update(teacher_id: @teacher.id)
    end

    return if performed?

    render json: {
      user: {
        id: @user.id,
        email_address: @user.email_address,
        role: @user.role
      },
      teacher: {
        id: @teacher.id,
        name: @teacher.name,
        class_room: @class_room.classname
      }
    }, status: :created
  end

  def create_parent
    ActiveRecord::Base.transaction do
      schedule = Schedule.last
      @user = User.new(parent_params)
      @user.role = "parent"
      @user.role_name = params[:family_name]
      unless @user.save
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      @family = @user.family
      @family.update(name: params[:family_name], name_kana: params[:name_kana])
      children_params_list.each do |child_attrs|
        child = Child.new(name: child_attrs[:name], name_kana: child_attrs[:name_kana], family_id: @family.id, schedule_id: schedule.id)
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
      user: {
        id: @user.id,
        email_address: @user.email_address
      }
    }, status: :created
  end

  def bulk_destroy
    ids = params[:ids]
    User.where(id: ids).destroy_all
    render json: { message: "削除しました" }, status: :ok
  end

  def bulk_teacher_destroy
    ids = params[:ids]
    User.where(id: ids).destroy_all
    render json: { message: "削除しました" }, status: :ok
  end

  def destroy
    user = User.find(params[:id])
    user.destroy!
    render json: { message: "削除しました" }, status: :ok
  end

  def update_parent
    schedule = Schedule.order(created_at: :desc).first
    children = []
    user = User.find(params[:id])
    user.family.update!(name: params[:name])
    params[:children].each do |child_params|
      child = Child.find(child_params[:id])
      child.update!(name: child_params[:name], schedule_id: schedule&.id)
      child.class_rooms = ClassRoom.where(id: child_params[:class_room_ids])
      child.assignments.destroy_all
      children << child
    end
    render json: { message: "更新しました" }, status: :ok
  end

  def update_teacher
    teacher = User.find(params[:id]).teacher
    teacher.update!(name: params[:name])
    class_room = ClassRoom.find(params[:class_room_id])
    class_room.update!(teacher_id: teacher.id)
    render json: { message: "更新しました" }, status: :ok
  end

  def show_parent
    user = User.find(params[:id])
    children = user.family.children.includes(:class_rooms).map do |child|
      {
        id: child.id,
        name: child.name,
        class_room_ids: child.class_rooms.map { |c| c.id }
      }
    end
    render json: { children: children }, status: :ok
  end



  private

  def teacher_params
    params.require(:user).permit(:email_address, :password)
  end

  def children_params_list
    params.require(:children).map do |child|
      child.permit(:name, :name_kana, :class_room_id)
    end
  end

  def parent_params
    params.require(:user).permit(:email_address, :password)
  end
end
