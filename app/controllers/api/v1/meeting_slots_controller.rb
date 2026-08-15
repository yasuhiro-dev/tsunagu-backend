class Api::V1::MeetingSlotsController < ApplicationController
  before_action -> { authorize_role!("teacher", "parent") }, only: [ :index ]
  before_action -> { authorize_role!("parent") }, only: [ :all ]
  before_action -> { authorize_role!("teacher") }, only: [ :bulk_update ]

  def all
    family = current_user.family
    teacher_ids = family.children.flat_map { |child| child.class_rooms.map(&:teacher_id) }
    slots = MeetingSlot.where(teacher_id: teacher_ids).includes(assignments: :child)

    slots = slots.group_by(&:start_at).map { |_, s| s.first }

    render json: slots.map { |slot|
      {
        id: slot.id,
        start_at: slot.start_at,
        end_at: slot.end_at,
        status: slot.status,
        child_name: slot.assignments.first&.child&.name
      }
    }
  end
  # 面談不可日程を更新する（教師）
  def bulk_update
    # 面談不可日程（ログイン中の先生別）
    meeting_slot_blocked = MeetingSlot.where(id: params[:meeting_slot_ids], teacher_id: current_user.teacher.id)
    # reservedにblockを上書きしないバリデーション
    if meeting_slot_blocked.any? { |slot|slot.reserved? }
      render json: { error: "予約済みに保護者が含まれています" }, status: :unprocessable_entity
      return
    end
    meeting_slot_blocked.update_all(status: :blocked)
    render json: meeting_slot_blocked, status: :ok
  end


  # 面談表を複製するメソッド
  def index
    if current_user.role == "teacher"
      teacher = current_user.teacher
      slots = MeetingSlot.where(teacher: teacher).includes(assignments: :child)
      # スロットが存在しないなら、面談表を作成する
      if slots.empty?
        schedule = Schedule.order(created_at: :desc).first
        existing_slots = MeetingSlot.where(schedule_id: schedule, teacher_id: Teacher.first.id)
        existing_slots.each do |existing_slot|
          MeetingSlot.create!(
            schedule: schedule,
            teacher: teacher,
            start_at: existing_slot.start_at,
            end_at: existing_slot.end_at
          )
        end
        slots = MeetingSlot.where(teacher: teacher).includes(assignments: :child)
      end
      render json: slots.map { |slot|
        {
          id: slot.id,
          start_at: slot.start_at,
          end_at: slot.end_at,
          status: slot.status,
          child_name: slot.assignments.first&.child&.name,
          assignment_id: slot.assignments.first&.id
        }
      }
    else
      family = current_user.family
      assignments = Assignment.joins(:meeting_slot, :child)
                              .where(children: { family: family })
                              .includes(:child, meeting_slot: { teacher: :class_rooms })
      render json: assignments.map { |a|
        {
          id: a.id,
          child_name: a.child.name,
          class_name: a.meeting_slot.teacher.class_rooms.first.classname,
          start_at: a.meeting_slot.start_at,
          end_at: a.meeting_slot.end_at
        }
      }
    end
  end
end
