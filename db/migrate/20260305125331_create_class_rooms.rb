class CreateClassRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :class_rooms do |t|
      t.integer :grade
      t.integer :section

      t.timestamps
    end
  end
end
