module Scheduling
  class AvailableSlots
    def initialize (schedule)
        @schedule = schedule
    end

    def call(group)
        teacher_ids = group.map do |g|
            room_type = g[:type] == :support ? "support" : "normal"
            g[:child].class_rooms.where(room_type: room_type).first&.teacher_id
        end .compact

        MeetingSlot.where(schedule: @schedule)
                   .where(teacher_id: teacher_ids)
                   .where.not(id: Assignment.select(:meeting_slot_id))
    end
  end
end
