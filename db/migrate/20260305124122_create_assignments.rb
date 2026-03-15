class CreateAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :assignments do |t|
      t.references :child, null: false, foreign_key: true
      t.references :meeting_slot, null: false, foreign_key: true

      t.timestamps
    end
  end
end
