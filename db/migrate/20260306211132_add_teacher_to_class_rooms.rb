class AddTeacherToClassRooms < ActiveRecord::Migration[8.1]
  def change
    add_reference :class_rooms, :teacher, null: false, foreign_key: true
  end
end
