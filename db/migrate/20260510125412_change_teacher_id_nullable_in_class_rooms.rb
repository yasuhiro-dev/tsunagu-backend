class ChangeTeacherIdNullableInClassRooms < ActiveRecord::Migration[8.1]
  def change
    change_column_null :class_rooms, :teacher_id, true
  end
end
