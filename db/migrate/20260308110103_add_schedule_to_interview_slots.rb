class AddScheduleToInterviewSlots < ActiveRecord::Migration[7.0]
  def change
    add_reference :meeting_slots, :schedule, foreign_key: true
  end
end
