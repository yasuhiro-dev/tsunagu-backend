class FixForeignKeyColumnTypes < ActiveRecord::Migration[8.1]
  def change
    change_column :class_rooms, :teacher_id, :bigint
    change_column :families, :user_id, :bigint
    change_column :meeting_slots, :schedule_id, :bigint
    change_column :meeting_slots, :teacher_id, :bigint, null: false
    change_column :sessions, :user_id, :bigint, null: false
    change_column :teachers, :user_id, :bigint
  end
end
