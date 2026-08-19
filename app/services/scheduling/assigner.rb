module Scheduling
  class Assigner
    # schedule_assignerから呼ばれる

    def call (slots, group)
      unassigned = []
      group.each do |g|
      room_type = g[:type] == :support ? "support" : "normal"
      # 通常級の場合先生１人のid/支援級の場合、通常級＋支援級の先生のid
      teacher_id = g[:child].class_rooms
                            .where(room_type: room_type)
                            .first&.teacher_id
      # 担任の先生の取得可能な面談slotを見つける
      slot = slots.find { |s| s.teacher_id == teacher_id && s.status == "available" }
      # 見つからなかった場合、その児童をunassigned[]に入れて、次の処理へ
      if slot.nil?
        unassigned << g[:child]
        next
      end
      # 見つかった場合、割り当てし、statusをreservedに変更する
      Assignment.create!(
        child_id: g[:child].id,
        meeting_slot_id: slot.id
      )
      slot.update!(status: "reserved")
      end
         unassigned
    end
  end
end
