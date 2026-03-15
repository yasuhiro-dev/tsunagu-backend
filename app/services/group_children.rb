class GroupChildren
  def initialize(schedule)
    @schedule = schedule
  end

  def call
    groups = build_groups
    groups
  end

  private

  def build_groups
    groups = []

    children = @schedule.children
    siblings = children.group_by(&:family_id)

    siblings.each do |family_id, family_children|

      if family_children.size > 1
        groups << family_children

      else
        child = family_children.first

        if child.class_rooms.support.any?
          groups << [
            { child: child, type: :normal },
            { child: child, type: :support }
          ]
        else
          groups << [child]
        end

      end

    end

    groups
  end
end