class AddClassNameToClassRooms < ActiveRecord::Migration[8.1]
  def change
    add_column :class_rooms, :classname, :string
  end
end
