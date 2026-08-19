module Scheduling
  class ScheduleAssigner
    def initialize(schedule, children)
        @schedule = schedule
        @children = children
    end

    def call
    # assignerからの戻り値を受け取る箱を用意
    unassigned = []
    # 兄弟・特別支援・一人っ子などのグループにまとめる
    groups = GroupChildren.new(@schedule, @children).call
    # グループごとに優先順位をつける
    sorted_groups = PrioritySort.new.call(groups)
      # 優先順位のグループごとに処理する
      sorted_groups.each do |group|
          # 各ファイルで割り当てに関わる制約を確認する
          slots = AvailableSlots.new(@schedule).call(group)
          slots = TimeFilter.new.call(slots, group)
          slots = SiblingsFilter.new.call(slots, group)
          slots = SupportFilter.new.call(slots, group)
          # 割り当てられるslotがなかったら、unassignedの箱に入れる
          if slots.empty?
            unassigned_child = group.map { |c|c[:child] }

            unassigned.concat(unassigned_child)
            next
          end
      # 割り当て実行ファイルを呼ぶ
      unassigned_children = Assigner.new.call(slots, group)

      # assignerからの戻り値を[]で受け取る
      unassigned.concat(unassigned_children)
      end
        # 戻り値(scheule_controllerへ)
        unassigned
    end
  end
end
