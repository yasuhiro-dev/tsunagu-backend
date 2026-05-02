class Api::V1::MeetingSlotsController < ApplicationController
    before_action :authenticate_user!
def index
  if current_user.role == "teacher"
    teacher = current_user.teacher
    slots = MeetingSlot.where(teacher: teacher)

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

    render json: assignments.map { |a|
    class_room = a.child.child_class_rooms.first&.class_room
      {
        child_name: a.child.name,
        class_name: class_room&.classname,
        start_at: a.meeting_slot.start_at,
        end_at: a.meeting_slot.end_at
        }
      }
  end
  end
end
