class Api::V1::MeetingSlotsController < ApplicationController
  before_action -> { authorize_role!("teacher", "parent") }, only: [ :index ]
  before_action -> { authorize_role!("parent") }, only: [ :all, :blocked_slots ]
  before_action -> { authorize_role!("teacher") }, only: [ :bulk_update ]

  # 割り当て児童やslotの情報を取得する
  def all
    slots = current_user.family.selectable_slots

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

  # 面談できる日時を更新する（教師）
  # 送られてきた枠を面談可、それ以外の枠を面談不可にする
  def bulk_update
    teacher_slots = MeetingSlot.where(teacher_id: current_user.teacher.id)
    available_ids = Array(params[:meeting_slot_ids]).map(&:to_i)
    # reservedにblockを上書きしないバリデーション
    if teacher_slots.where.not(id: available_ids).exists?(status: :reserved)
      render json: { error: "予約済みの枠は面談不可にできません" }, status: :unprocessable_entity
      return
    end
    ActiveRecord::Base.transaction do
      teacher_slots.where(id: available_ids, status: :blocked).update_all(status: :available)
      teacher_slots.where.not(id: available_ids).where(status: :available).update_all(status: :blocked)
    end
    render json: teacher_slots, status: :ok
  end

  # 教師の面談表不可日程を保護者に反映
  def blocked_slots
    # 現在ログイン中のユーザーからを取得
    family = current_user.family
    class_rooms = family.children.flat_map { |c|c.class_rooms }
    teacher = class_rooms.map { |r|r.teacher }
    status = teacher.flat_map { |t|t.meeting_slots.where(status: :blocked) }
  render json: status
  end

  # ログイン中の先生の面談表を取得する
  def index
    # ログイン中のroleが先生の場合
    if current_user.role == "teacher"
      teacher = current_user.teacher
      slots = MeetingSlot.where(teacher: teacher).includes(assignments: { child: :family })
      render json: slots.map { |slot|
        {
          id: slot.id,
          start_at: slot.start_at,
          end_at: slot.end_at,
          status: slot.status,
          child_name: slot.assignments.first&.child&.name,
          assignment_id: slot.assignments.first&.id,
          submitted: slot.assignments.first&.child&.family&.submitted
        }
      }
    else
      # ログイン中のroleが保護者の場合
      family = current_user.family
      assignments = Assignment.joins(:meeting_slot, :child)
                              .where(children: { family: family })
                              .includes(:child, meeting_slot: { teacher: :class_rooms })
                              .order("meeting_slots.start_at")
      render json: assignments.map { |a|
        {
          id: a.id,
          child_id: a.child.id,
          child_name: a.child.name,
          class_name: a.meeting_slot.teacher.class_rooms.first.classname,
          room_type: a.meeting_slot.teacher.class_rooms.first.room_type,
          start_at: a.meeting_slot.start_at,
          end_at: a.meeting_slot.end_at
        }
      }
    end
  end
  # ログイン中の先生の面談表を作成する
  def create
        schedule = Schedule.current
        teacher = current_user.teacher
        existing_slots = MeetingSlot.where(schedule_id: schedule, teacher_id: Teacher.first.id)
        existing_slots.each do |existing_slot|
          MeetingSlot.create!(
            schedule: schedule,
            teacher: teacher,
            start_at: existing_slot.start_at,
            end_at: existing_slot.end_at
          )
        end
        create_meeting_slots = MeetingSlot.where(teacher: teacher).includes(assignments: :child)
        render json: create_meeting_slots.map { |c|
      {
          id: c.id,
          start_at: c.start_at,
          end_at: c.end_at,
          status: c.status,
          child_name: c.assignments.first&.child&.name,
          assignment_id: c.assignments.first&.id
      }}
  end
end
