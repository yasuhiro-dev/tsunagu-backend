module Scheduling
  class SiblingsFilter
    SLOT_INTERVAL_MINUTES = 15

   def call(slots, group)
  return slots unless siblings_group?(group)

  unavailable_ids = group.map { |g| g[:child] }
                         .flat_map { |child| child.family.family_unavailabilities.pluck(:meeting_slot_id) }
                         .uniq

  normal_support_entries = group.select { |g| g[:type] == :normal || g[:type] == :support }
 child_slot_candidates = normal_support_entries.map do |entry|
  room_type = entry[:type] == :support ? "support" : "normal"
  teacher_id = entry[:child].class_rooms.where(room_type: room_type).first&.teacher_id
  slots.select { |s| s.teacher_id == teacher_id }
end

  child_slot_candidates.first.product(*child_slot_candidates[1..]).each do |combo|
    combo.permutation.each do |ordered|
     next if ordered.any? { |s| unavailable_ids.include?(s.id) || s.status == "reserved" }
      return ordered if consecutive?(ordered)
    end
  end
  []
end

    private

    def siblings_group?(group)
     group.count { |g| g[:type]==:normal || g[:type]==:support }>1
    end

    def consecutive?(slots)
      slots.each_cons(2).all? do |s1, s2|
        s2.start_at == s1.start_at + SLOT_INTERVAL_MINUTES*60 &&
        s1.start_at.to_date == s2.start_at.to_date
      end
    end
  end
end
