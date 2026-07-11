module Scheduling
  class SupportFilter
    SLOT_INTERVAL_MINUTES = 15

    def call(slots, group)
      return slots unless support_group?(group)

      support_entry = group.find { |g| g[:type] == :support }
      support_teacher_id = support_entry[:child].class_rooms
                                                .where(room_type: "support")
                                                .first&.teacher_id
      return slots if support_teacher_id.nil?

      normal_teacher_id = support_entry[:child].class_rooms
                                               .where(room_type: "normal")
                                               .first&.teacher_id

      normal_slots = slots.select { |s| s.teacher_id == normal_teacher_id }
      return slots if normal_slots.empty?

normal_slots.each do |normal_slot|
  support_slot = slots.find { |s|
    s.teacher_id == support_teacher_id &&
    consecutive?(normal_slot, s)
  }

  sibling_slots = slots.reject { |s|
    s.teacher_id == normal_teacher_id || s.teacher_id == support_teacher_id
  }
  return [ normal_slot, support_slot ] + sibling_slots if support_slot
end

      []
    end

    private

    def support_group?(group)
      group.any? { |g| g[:type] == :support }
    end

    def consecutive?(slot1, slot2)
      slot2.start_at == slot1.start_at + SLOT_INTERVAL_MINUTES * 60 ||
slot1.start_at == slot2.start_at + SLOT_INTERVAL_MINUTES * 60
    end
  end
end
