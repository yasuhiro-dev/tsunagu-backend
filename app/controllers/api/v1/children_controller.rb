class Api::V1::ChildrenController<ApplicationController
    def index
        teacher = current_user.teacher
        children = Child.includes(:family)
        .joins(:child_class_rooms)
        .where(child_class_rooms: { class_room_id: teacher.class_room_ids})
        render json: children.map { |c| {
            id: c.id,
            child_name: c.name,
            family_name: c.family.name,
            submitted: c.family.submitted,
            assigned: c.assignments.exists?
            }}, status: :ok
    end

    def unassigned
        children = Child.includes(:family).where.not(id: Assignment.select(:child_id))
        render json: children.map { |c|{
            id: c.id,
            child_name: c.name,
            family_name: c.family.name
        }}, status: :ok
    end
end
