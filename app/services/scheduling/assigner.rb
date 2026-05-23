module Scheduling
  class Assigner
    def call (slots, group)
      group.each do |g|
      room_type = g[:type] == :support ? "support" : "normal"
      teacher_id = g[:child].class_rooms
                            .where(room_type: room_type)
                            .first&.teacher_id
      slot = slots.find { |s| s.teacher_id == teacher_id && s.status == "available" }
      next if slot.nil?
      Assignment.create!(
        child_id: g[:child].id,
        meeting_slot_id: slot.id
      )
      slot.update!(status: "reserved")
      end
    end
  end
end
