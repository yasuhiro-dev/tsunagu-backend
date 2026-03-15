class AddRoomTypeToClassRoom < ActiveRecord::Migration[8.1]
  def change
    add_column :class_rooms, :room_type, :integer
  end
end
