class AssignSupport
def initialize(schedule, groups)
    @schedule = schedule
    @groups = groups
    @slots = schedule.meeting_slots.order(:start_time)
end

def call
  @groups.each do |group|
    next unless support_group?(group)

    child = group.first[:child]
    next if child.assignments.exists?

    assign_support(child)
  end
end

private

def support_group?(group)
    group.any? { |g| g.is_a?(Hash) && g[:type] == :support }
end


def assign_support(child)
    @slots.each do |slot|
        next unless slot_empty?(slot)
        next_time = slot.start_time + 15.minutes

        support_slot =
        MeetingSlot.find_by(
            teacher: support_teacher,
            start_time: next_time
        )
        next unless support_slot
        next unless slot_empty?(support_slot)

Assignment.create!(
    child: child,
    meeting_slot: slot,
    meeting_type: :normal
)
Assignment.create!(
    child: child,
    meeting_slot: support_slot,
    meeting_type: support
)
break
    end
end
end
