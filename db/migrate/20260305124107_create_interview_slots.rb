class CreateInterviewSlots < ActiveRecord::Migration[7.0]
  def change
    create_table :meeting_slots do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.references :teacher, null: false, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end
