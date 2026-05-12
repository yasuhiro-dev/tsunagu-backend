module Scheduling
  class TimeFilter
    def call(slots, group)
      unavailable_slot_ids = group.map { |g| g[:child] }
                                  .flat_map { |child| child.family.family_unavailabilities.pluck(:meeting_slot_id) }
                                  .uniq

      unavailable_times = MeetingSlot.where(id: unavailable_slot_ids).pluck(:start_at)

      slots.reject { |s| unavailable_times.include?(s.start_at) }
    end
  end
end