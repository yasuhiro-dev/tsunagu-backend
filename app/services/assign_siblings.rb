class AssignSiblings

  def initialize(schedule)
    @schedule = schedule
  end

  def call

    children = @schedule.children
    sibling_groups = children.group_by(&:family_id)

    sibling_groups.each do |family_id, siblings|

      next if siblings.size < 2

      count = siblings.size

      slots = @schedule.interview_slots.order(:start_at)

      slots.each_cons(count) do |slot_group|

        if slot_group.all? { |slot| slot.status == "available" }

          siblings.each_with_index do |child, index|

            slot = slot_group[index]

            Assignment.create!(
              child: child,
              interview_slot: slot
            )

            slot.update!(status: "reserved")

          end

          break
        end

      end
    end
  end
end