module Scheduling
  class SiblingsFilter
    SLOT_INTERVAL_MINUTES = 15
def call(slots, group)
  return slots unless siblings_group?(group)

  normal_entries = group.select { |g| g[:type] == :normal }
  child_slot_candidates = normal_entries.map do |entry|
    teacher_id = entry[:child].class_rooms.where(room_type: "normal").first&.teacher_id
    result = slots.select { |s| s.teacher_id == teacher_id }
    puts "=== #{entry[:child].name} の候補slots: #{result.map(&:id)} ==="
    result
  end

  child_slot_candidates.first.product(*child_slot_candidates[1..]).each do |combo|
    combo.permutation.each do |ordered|
      puts "=== 試したcombo: #{ordered.map(&:id)} ==="
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
        s2.start_at == s1.start_at + SLOT_INTERVAL_MINUTES*60 &&
        s1.start_at.to_date == s2.start_at.to_date 
      end
    end
  end
end
