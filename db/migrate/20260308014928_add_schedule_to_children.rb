class AddScheduleToChildren < ActiveRecord::Migration[8.1]
  def change
    add_reference :children, :schedule, foreign_key: true
  end
end
