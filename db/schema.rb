# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_01_125604) do
  create_table "assignments", force: :cascade do |t|
    t.integer "child_id", null: false
    t.datetime "created_at", null: false
    t.integer "meeting_slot_id", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id", "meeting_slot_id"], name: "index_assignments_on_child_id_and_meeting_slot_id", unique: true
    t.index ["child_id"], name: "index_assignments_on_child_id"
    t.index ["meeting_slot_id"], name: "index_assignments_on_meeting_slot_id"
  end

  create_table "child_class_rooms", force: :cascade do |t|
    t.integer "child_id", null: false
    t.integer "class_room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_child_class_rooms_on_child_id"
    t.index ["class_room_id"], name: "index_child_class_rooms_on_class_room_id"
  end

  create_table "children", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "family_id", null: false
    t.string "name"
    t.integer "schedule_id"
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_children_on_family_id"
    t.index ["schedule_id"], name: "index_children_on_schedule_id"
  end

  create_table "children_teachers", force: :cascade do |t|
    t.integer "child_id", null: false
    t.datetime "created_at", null: false
    t.integer "teacher_id", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_children_teachers_on_child_id"
    t.index ["teacher_id"], name: "index_children_teachers_on_teacher_id"
  end

  create_table "class_rooms", force: :cascade do |t|
    t.string "classname"
    t.datetime "created_at", null: false
    t.integer "grade"
    t.integer "room_type"
    t.integer "section"
    t.integer "teacher_id"
    t.datetime "updated_at", null: false
    t.index ["teacher_id"], name: "index_class_rooms_on_teacher_id"
  end

  create_table "families", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "name_kana"
    t.boolean "submitted"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "family_unavailabilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "family_id", null: false
    t.integer "meeting_slot_id", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_family_unavailabilities_on_family_id"
    t.index ["meeting_slot_id"], name: "index_family_unavailabilities_on_meeting_slot_id"
  end

  create_table "meeting_slots", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_at"
    t.integer "schedule_id"
    t.datetime "start_at"
    t.integer "status"
    t.integer "teacher_id", null: false
    t.datetime "updated_at", null: false
    t.index ["schedule_id"], name: "index_meeting_slots_on_schedule_id"
    t.index ["teacher_id"], name: "index_meeting_slots_on_teacher_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "year"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "teachers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "role"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address"
    t.string "name"
    t.string "password_digest"
    t.string "role"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "assignments", "children"
  add_foreign_key "assignments", "meeting_slots"
  add_foreign_key "child_class_rooms", "children"
  add_foreign_key "child_class_rooms", "class_rooms"
  add_foreign_key "children", "families"
  add_foreign_key "children", "schedules"
  add_foreign_key "children_teachers", "children", on_delete: :cascade
  add_foreign_key "children_teachers", "teachers"
  add_foreign_key "class_rooms", "teachers"
  add_foreign_key "family_unavailabilities", "families"
  add_foreign_key "family_unavailabilities", "meeting_slots"
  add_foreign_key "meeting_slots", "schedules"
  add_foreign_key "meeting_slots", "teachers"
  add_foreign_key "sessions", "users"
end
