class Api::V1::ChildrenController<ApplicationController
    before_action -> { authorize_role!("teacher") }
    def index
        teacher = current_user.teacher
        children = Child.includes(:family, :assignments)
        .joins(:child_class_rooms)
        .where(child_class_rooms: { class_room_id: teacher.class_room_ids })
        render json: children.map { |c| {
            id: c.id,
            child_name: c.name,
            child_name_kana: c.name_kana,
            family_name: c.family.name,
            submitted: c.family.submitted,
            assigned: c.assignments.any?
            }}, status: :ok
    end

    def unassigned
        children = Child.includes(:family).where.not(id: Assignment.select(:child_id))
        render json: children.map { |c|{
            id: c.id,
            child_name: c.name,
            family_name: c.family.name,
            child_name_kana: c.name_kana
        }}, status: :ok
    end
end
