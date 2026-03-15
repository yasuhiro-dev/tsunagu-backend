class AddScheduleToInterviewSlots < ActiveRecord::Migration[8.1]
  def change
    add_reference :interview_slots, :schedule, foreign_key: true
  end
end
