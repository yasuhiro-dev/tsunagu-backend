module Scheduling
    class TimeFilter
        def call(slots, group)
            unavailable_slots_ids = group.first[:child]
                                         .family
                                         .family_unavailabilities
                                         .pluck(:meeting_slot_id)
            slots.reject { |s|unavailable_slots_ids.include?(s.id) }
        end
    end
end
