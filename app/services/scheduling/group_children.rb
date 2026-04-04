module Scheduling
  class GroupChildren
    def initialize(schedule)
      @schedule = schedule
    end

    def call
      groups = []
      children = @schedule.children
      siblings = children.group_by(&:family_id)

      siblings.each do |family_id, family_children|
        if family_children.size > 1
          group = family_children.map { |c| { child: c, type: :normal } }
          support_child = family_children.find { |c| c.class_rooms.where(room_type: "support").any? }
          group << { child: support_child, type: :support } if support_child
          groups << group
        else
          child = family_children.first
          if child.class_rooms.where(room_type: "support").any?
            groups << [
              { child: child, type: :normal },
              { child: child, type: :support }
            ]
          else
            groups << [ { child: child, type: :normal } ]
          end
        end
      end

      groups
    end
  end
end
