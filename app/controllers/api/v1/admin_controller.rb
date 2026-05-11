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
               children_name: u.family&.children&.map(&:name),
               children_class: u.family&.children&.map do |c|
  c.class_rooms.map { |cr| "#{cr.grade}年#{cr.section}組" }.join(", ")
end
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
      def destroy
            user = User.find(params[:id])
            user.destroy!
            render json: { message: "削除しました" }, status: :ok
        end

    def update
        ActiveRecord::Base.transaction do
            user = User.find(params[:id])

            user.update!(email_address: params[:email_address]) if params[:email_address]
            user.update!(password: params[:password]) if params[:password]

            if user.role == "teacher"
                user.teacher.update!(name: params[:name]) if params[:name]
                if params[:class_room_id]
                    ClassRoom.where(teacher_id: [ user.teacher.id ]).update_all(teacher_id: nil)
                    class_room = ClassRoom.find(params[:class_room_id])
                    class_room.update!(teacher_id: user.teacher.id)
                end
            end
        end
    end


    private

def teacher_params
  params.require(:user).permit(:email_address, :password)
end
end
