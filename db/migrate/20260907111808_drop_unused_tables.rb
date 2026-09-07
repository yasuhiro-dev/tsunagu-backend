class DropUnusedTables < ActiveRecord::Migration[8.1]
  def change
    drop_table :sessions do |t|
      t.datetime "created_at", null: false
      t.string "ip_address"
      t.datetime "updated_at", null: false
      t.string "user_agent"
      t.bigint "user_id", null: false
      t.index ["user_id"], name: "index_sessions_on_user_id"
    end

    drop_table :children_teachers do |t|
      t.bigint "child_id"
      t.datetime "created_at", null: false
      t.bigint "teacher_id"
      t.datetime "updated_at", null: false
      t.index ["child_id"], name: "index_children_teachers_on_child_id"
      t.index ["teacher_id"], name: "index_children_teachers_on_teacher_id"
    end
  end
end