class Api::V1::AdminController < ApplicationController
    def index
        teachers = User.where(role: "teacher").includes(teacher: { class_rooms: [] })
        parents = User.where(role: "parent").includes(family: { children: [] })

        render json: {
            teachers: teachers.map { |u|{
                id: u.id,
               email_address: u.email_address,
                name: u.teacher&.name,
                class_room: u.teacher&.class_rooms&.map { |c| "#{c.grade}年#{c.section}組" }
            }
            },
            parents: parents.map { |u|{
                id: u.id,
               email_address: u.email_address,
               name: u.family&.name,
               children_name: u.family&.children&.map(&:name)
            }} }, status: :ok
    end
    def create_teacher
        ActiveRecord::Base.transaction do
            @user=User.new(teacher_params)
            @user.role = "teacher"
            unless @user.save
                render json: { error: @user.errors.full_messages },
                status: :unprocessable_entity
                raise ActiveRecord::Rollback
            end
            @teacher=@user.teacher
            @teacher.update(name: params[:name])

            @class_room=ClassRoom.find(params[:class_room_id])
            @class_room.update(teacher_id: @teacher.id)
        end

        return if performed?

        render json: {
            user: {
                id: @user.id,
                email_address: @user.email_address
            },
            teacher: {
                id: @teacher.id,
                name: @teacher.name,
                class_room: @class_room.classname
            }
            }, status: :created
    end
    private

def teacher_params
  params.require(:user).permit(:email_address, :password)
end
end
