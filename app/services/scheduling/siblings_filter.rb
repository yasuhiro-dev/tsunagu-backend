module Scheduling
  class SiblingsFilter
    SLOT_INTERVAL_MINUTES = 15

  def call(slots, group)
  return slots unless siblings_group?(group)

  # 担任の先生の面談slotを取り出す
  child_slot_candidates = group.map do |entry|
  # room_typeを特別支援と通常級で分ける
  room_type = entry[:type] == :support ? "support" : "normal"
  # 担任（通常級・支援級）の先生を割り出す
  teacher_id = entry[:child].class_rooms.where(room_type: room_type).first&.teacher_id
  # 面談表と担任の先生を一致させる
  slots.select { |s| s.teacher_id == teacher_id }
end

  child_slot_candidates.first.product(*child_slot_candidates[1..]).each do |combo|
    combo.permutation.each do |ordered|
     # 時間不可が含まれている又はそのslotがreservedの時は割り当てない
     next if ordered.any? { |s| s.status == "reserved" }

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
