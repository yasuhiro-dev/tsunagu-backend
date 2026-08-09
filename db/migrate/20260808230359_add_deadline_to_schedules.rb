class AddDeadlineToSchedules < ActiveRecord::Migration[8.1]
  def change
    add_column :schedules, :deadline_at, :datetime
  end
end
