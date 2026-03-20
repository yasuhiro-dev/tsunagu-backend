class ScheduleService
  def initialize(schedule, groups)
    @schedule = schedule
    @groups = groups
  end

  def assign_all
    GroupChildren.new(@schedule).call

    AssignSiblings.new(@schedule).call
    AssignSupport.new(@schedule, @groups).call
    AssignTimeConstraints.new(@schedule).call
    AssignNormal.new(@schedule).call
  end
end
