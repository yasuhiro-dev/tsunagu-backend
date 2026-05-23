class AddUniqueIndexToAssignments < ActiveRecord::Migration[8.1]
 def change
add_index :assignments, [ :child_id, :meeting_slot_id ], unique: true
end
end
