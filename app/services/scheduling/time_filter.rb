module Scheduling
  class TimeFilter
    def call(slots, group)
      # 提出済みの家庭は、参加できると答えた時刻の枠だけを残す
      # （idではなく時刻で見ることで兄弟間で不具合が起こらない）
      # 未提出の家庭は、途中まで入力していても制約なしとして扱う
      families = group.map { |g| g[:child].family }.uniq.select(&:submitted)
      return slots if families.empty?

      # 事前ロード済みのmeeting_slotを辿るだけにして、グループごとのクエリをなくす
      available_start_at = families.map do |family|
        family.family_availabilities.map { |item| item.meeting_slot&.start_at }.compact
      end
      slots.select { |s| available_start_at.all? { |start_at| start_at.include?(s.start_at) } }
    end
  end
end
