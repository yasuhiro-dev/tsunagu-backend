class RemoveClassRoomFromChildren < ActiveRecord::Migration[8.1]
  def change
    remove_reference :children, :class_room, null: false, foreign_key: true
  end
end
