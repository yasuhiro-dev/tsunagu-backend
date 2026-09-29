class CreateAssignmentNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :assignment_notifications do |t|
      t.references :child, null: false, foreign_key: true
      t.references :meeting_slot, null: false, foreign_key: true
      t.datetime :sent_at, null: false

      t.timestamps
    end
    add_index :assignment_notifications, [ :child_id, :meeting_slot_id ], unique: true
  end
end
