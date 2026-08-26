module Scheduling
  class TimeFilter
    def call(slots, group)
      # 保護者の割り当て不可日のstart_atを取得する
      # （idではなく時刻で見ることで兄弟間で不具合が起こらない）
      # 事前ロード済みのmeeting_slotを辿るだけにして、グループごとのクエリをなくす
      start_at = group.map { |g| g[:child] }
                      .flat_map { |child| child.family.family_unavailabilities.map { |item| item.meeting_slot&.start_at } }
                      .compact
                      .uniq
      # 全slotを見て、不可日slotと比較し、被っていたらを弾く（start_at）
      slots.reject { |s| start_at.include?(s.start_at) }
    end
  end
end
