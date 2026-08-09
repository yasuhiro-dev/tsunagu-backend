class Api::V1::MeetingSlotsController < ApplicationController
  before_action -> { authorize_role!("teacher", "parent") }, only: [ :index ]
  before_action -> { authorize_role!("parent") }, only: [ :all ]

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
        child_name: slot.assignments.first&.child&.name,
        schedule_id: slot.schedule_id
      }
    }
  end

  def index
    if current_user.role == "teacher"
      teacher = current_user.teacher
      slots = MeetingSlot.where(teacher: teacher).includes(assignments: :child)

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
          child_name: slot.assignments.first&.child&.name
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
