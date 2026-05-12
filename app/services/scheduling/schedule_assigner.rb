module Scheduling
  class ScheduleAssigner
    def initialize(schedule)
        @schedule = schedule
    end

    def call
    groups = GroupChildren.new(@schedule).call
    sorted_groups = PrioritySort.new.call(groups)
    sorted_groups.each do |group|
      puts "=== group: #{group.map { |g| g[:child].name }} ===" 
        slots = AvailableSlots.new(@schedule).call(group)
        slots = TimeFilter.new.call(slots, group)
        slots = SiblingsFilter.new.call(slots, group)
        slots = SupportFilter.new.call(slots, group)
        next if slots.empty?
        Assigner.new.call(slots, group)
        end
    end
  end
end
