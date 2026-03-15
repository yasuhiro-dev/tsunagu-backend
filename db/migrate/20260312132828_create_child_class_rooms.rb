class CreateChildClassRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :child_class_rooms do |t|
      t.references :child, null: false, foreign_key: true
      t.references :class_room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
