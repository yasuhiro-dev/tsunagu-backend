class ChangeIntegerToBigintForForeignKeys < ActiveRecord::Migration[8.1]
  def up
    execute("SET FOREIGN_KEY_CHECKS=0")
    change_column :assignments, :child_id, :bigint
    change_column :assignments, :meeting_slot_id, :bigint
    change_column :child_class_rooms, :child_id, :bigint
    change_column :child_class_rooms, :class_room_id, :bigint
    change_column :children, :family_id, :bigint
    change_column :children, :schedule_id, :bigint
    change_column :children_teachers, :child_id, :bigint
    change_column :children_teachers, :teacher_id, :bigint
    change_column :family_unavailabilities, :family_id, :bigint
    change_column :family_unavailabilities, :meeting_slot_id, :bigint
    execute("SET FOREIGN_KEY_CHECKS=1")
  end

  def down
    execute("SET FOREIGN_KEY_CHECKS=0")
    change_column :assignments, :child_id, :integer
    change_column :assignments, :meeting_slot_id, :integer
    change_column :child_class_rooms, :child_id, :integer
    change_column :child_class_rooms, :class_room_id, :integer
    change_column :children, :family_id, :integer
    change_column :children, :schedule_id, :integer
    change_column :children_teachers, :child_id, :integer
    change_column :children_teachers, :teacher_id, :integer
    change_column :family_unavailabilities, :family_id, :integer
    change_column :family_unavailabilities, :meeting_slot_id, :integer
    execute("SET FOREIGN_KEY_CHECKS=1")
  end
end
