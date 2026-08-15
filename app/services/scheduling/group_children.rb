module Scheduling
  class GroupChildren
    def initialize(schedule, children)
      @schedule = schedule
      @children = children
    end

    # schedule_assignerから呼ばれる
    def call
      groups = []
      children = @children.where(schedule_id: @schedule.id)
      # family_idで兄弟を判断する
      siblings = children.group_by(&:family_id)
      # 兄弟を判断するデータ・複数児童をまとめた箱に分けて管理
      siblings.each do |family_id, family_children|
        if family_children.size > 1
          # 通常級の児童
          group = family_children.map { |c| { child: c, type: :normal } }
          # 支援学級の児童
          support_child = family_children.find { |c| c.class_rooms.where(room_type: "support").any? }
          group << { child: support_child, type: :support } if support_child
          groups << group
        else

          child = family_children.first
          # 兄弟がいないかつ特別支援学級の場合
          if child.class_rooms.where(room_type: "support").any?
            groups << [
              # 通常級と特別支援学級に分けて管理する
              { child: child, type: :normal },
              { child: child, type: :support }
            ]
          else
            # 兄弟がいないかつ通常級場合
            groups << [ { child: child, type: :normal } ]
          end
        end
      end

      groups
    end
  end
end
