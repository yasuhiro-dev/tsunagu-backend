module Scheduling
  class SupportFilter
    SLOT_INTERVAL_MINUTES=15
    def call (slots, group)
      return slots unless support_group?(group)
      support_entries = group.select { |g|g[:type]== :support }
      support_slots = support_entries.map do |entry|
      support_teacher_id = entry[:child].class_rooms
                                       .where(room_type: "support")
                                       .first&.teacher_id
      return slots if support_teacher_id.nil?
      slots.find { |s|s.teacher_id==support_teacher_id && consecutive?(slots.last, s) }
      end.compact

      return [] if support_slots.empty?
      slots + support_slots
    end

    private
    def support_group?(group)
      group.any? { |g|g[:type]==:support }
    end

    def consecutive?(slot1, slot2)
      slot2.start_at == slot1.start_at + SLOT_INTERVAL_MINUTES * 60
    end
  end
end
