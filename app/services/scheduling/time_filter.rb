module Scheduling
  class TimeFilter
    def call(slots, group)

      unavailable_slots_ids = group.map { |g| g[:child] }
                                   .flat_map { |child| child.family.family_unavailabilities.pluck(:meeting_slot_id) }
                                   .uniq
      slots.reject { |s| unavailable_slots_ids.include?(s.id) }

    end
  end
end
