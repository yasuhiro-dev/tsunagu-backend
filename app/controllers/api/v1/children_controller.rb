class Api::V1::ChildrenController<ApplicationController
    before_action -> { authorize_role!("teacher") }
    # 割り当て児童を取得する
    def index
        teacher = current_user.teacher
        class_rooms = teacher.class_rooms
        children = Child.includes(:family, :assignments)
                        .joins(:child_class_rooms)
                        .where(child_class_rooms: { class_room_id: teacher.class_room_ids })
        render json: {
        class_names: class_rooms.pluck(:classname),
        children: children.map { |c| {
        id: c.id,
        child_name: c.name,
        child_name_kana: c.name_kana,
        family_name: c.family.name,
        submitted: c.family.submitted,
        assigned: c.assignments.any?
        } }
    }, status: :ok
    end
    # 未割り当て児童を取得する
    def unassigned
        teacher = current_user.teacher
        # 家庭が選んだ面談枠までまとめて読み込む（児童ごとにSQLが走るN+1を防ぐ）
        children = Child.includes(:assignments, family: { family_availabilities: :meeting_slot })
        .joins(:child_class_rooms)
        .where(child_class_rooms: { class_room_id: teacher.class_room_ids })
        unassigned_children = children.where.not(id: Assignment.select(:child_id))

        render json: unassigned_children.map { |c|{
            id: c.id,
            child_name: c.name,
            family_name: c.family.name,
            child_name_kana: c.name_kana,
            submitted: c.family.submitted,
            # 保護者が「参加できる」と答えた時刻（兄弟は担任ごとに枠が別なので、時刻でまとめる）
            available_start_at: c.family.family_availabilities.map { |a| a.meeting_slot&.start_at }.compact.uniq.sort
        }}, status: :ok
    end
end
