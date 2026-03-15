class ScheduleService
  def initialize(schedule)
    @schedule = schedule
  end

  def assign_all
GroupChildren.new(@schedule).call

    AssignSiblings.new(@schedule).call
    AssignSupport.new(@schedule).call
    AssignTimeConstraints.new(@schedule).call
    AssignNormal.new(@schedule).call
    
  end
end