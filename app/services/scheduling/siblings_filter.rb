module Scheduling
  class SiblingsFilter
    SLOT_INTERVAL_MINUTES = 15
    def call(slots, group)
      return slots unless siblings_group?(group)

      normal_entries = group.select { |g|g[:type]==:normal }
      child_slots = normal_entries.map do |entry|
        teacher_id = entry[:child].class_rooms.where(room_type: "normal")
        .first&.teacher_id
        slots.find { |s|s.teacher_id==teacher_id }
      end.compact

      child_slots.permutation.each do |ordered_slots|
        return slots if consecutive?(ordered_slots)
      end
      []
    end

    private

    def siblings_group?(group)
     group.count { |g|g[:type]==:normal }>1
    end

    def consecutive?(slots)
      slots.each_cons(2).all? do |s1, s2|
        s2.start_at == s1.start_at + SLOT_INTERVAL_MINUTES*60
      end
    end
  end
end
