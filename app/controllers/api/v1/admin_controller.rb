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
end
