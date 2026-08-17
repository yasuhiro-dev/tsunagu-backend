module Scheduling
  class TimeFilter
    def call(slots, group)
      # 保護者の割り当て不可日のid(meeting_slot_id)を取得する
      unavailable_slots_ids = group.map { |g| g[:child] }
                                   .flat_map { |child| child.family.family_unavailabilities.pluck(:meeting_slot_id) }
                                   .uniq
      # idからstart_atを割り出す（start_atにすることで兄弟間で不具合が起こらない）
      start_at = MeetingSlot.where(id: unavailable_slots_ids).pluck(:start_at)
      # 全slotを見て、不可日slotと比較し、被っていたらを弾く（start_at）
      slots.reject { |s| start_at.include?(s.start_at) }
    end
  end
end
