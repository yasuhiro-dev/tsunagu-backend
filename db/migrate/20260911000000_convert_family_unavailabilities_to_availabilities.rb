# 保護者の入力を「参加できない枠」から「参加できる枠」に置き換える
class ConvertFamilyUnavailabilitiesToAvailabilities < ActiveRecord::Migration[8.1]
  def up
    rename_table :family_unavailabilities, :family_availabilities
    invert_rows
  end

  def down
    invert_rows
    rename_table :family_availabilities, :family_unavailabilities
  end

  private

  # 既存の行の意味を反転させる（参加できない枠 ⇔ 参加できる枠）
  # 対象は、提出済みの家庭と、途中まで入力していた家庭
  # 反転後の枠は、保護者画面と同じく「担任の枠を開始時刻で重複除去したもの」から選ぶ
  def invert_rows
    family_ids = select_values(<<~SQL)
      SELECT id FROM families WHERE submitted = TRUE
      UNION
      SELECT DISTINCT family_id FROM family_availabilities
    SQL

    family_ids.each do |family_id|
      family_id = family_id.to_i
      selectable = select_rows(<<~SQL).uniq { |_id, start_at| start_at.to_s }
        SELECT meeting_slots.id, meeting_slots.start_at
        FROM meeting_slots
        WHERE meeting_slots.teacher_id IN (
          SELECT class_rooms.teacher_id
          FROM class_rooms
          INNER JOIN child_class_rooms ON child_class_rooms.class_room_id = class_rooms.id
          INNER JOIN children ON children.id = child_class_rooms.child_id
          WHERE children.family_id = #{family_id}
        )
        ORDER BY meeting_slots.id
      SQL
      current_start_at = select_values(<<~SQL).map(&:to_s)
        SELECT meeting_slots.start_at
        FROM family_availabilities
        INNER JOIN meeting_slots ON meeting_slots.id = family_availabilities.meeting_slot_id
        WHERE family_availabilities.family_id = #{family_id}
      SQL
      inverted_slot_ids = selectable.reject { |_id, start_at| current_start_at.include?(start_at.to_s) }.map(&:first)

      execute("DELETE FROM family_availabilities WHERE family_id = #{family_id}")
      next if inverted_slot_ids.empty?

      now = quote(Time.current.utc.to_fs(:db))
      values = inverted_slot_ids.map { |slot_id| "(#{family_id}, #{slot_id.to_i}, #{now}, #{now})" }.join(", ")
      execute("INSERT INTO family_availabilities (family_id, meeting_slot_id, created_at, updated_at) VALUES #{values}")
    end
  end
end
