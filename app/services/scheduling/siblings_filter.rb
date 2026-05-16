module Scheduling
  class SiblingsFilter
    SLOT_INTERVAL_MINUTES = 15
   def call(slots, group)
  return slots unless siblings_group?(group)

  # 最初に時間不可IDを取得しておく
  unavailable_ids = group.map { |g| g[:child] }
                         .flat_map { |child| child.family.family_unavailabilities.pluck(:meeting_slot_id) }
                         .uniq

  normal_entries = group.select { |g| g[:type] == :normal }
  child_slot_candidates = normal_entries.map do |entry|
    teacher_id = entry[:child].class_rooms.where(room_type: "normal").first&.teacher_id
    slots.select { |s| s.teacher_id == teacher_id }
  end

  child_slot_candidates.first.product(*child_slot_candidates[1..]).each do |combo|
    combo.permutation.each do |ordered|
      next if ordered.any? { |s| unavailable_ids.include?(s.id) }  # 時間不可を弾く
      return ordered if consecutive?(ordered)
    end
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
