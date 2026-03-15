class CreateSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :schedules do |t|
      t.string :name
      t.integer :year

      t.timestamps
    end
  end
end
