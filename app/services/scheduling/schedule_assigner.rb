module Scheduling
  class ScheduleAssigner
    def initialize(schedule, children)
        @schedule = schedule
        @children = children
    end

    def call
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
        next if slots.empty?
        # 割り当てをする
        Assigner.new.call(slots, group)
        end
    end
  end
end
