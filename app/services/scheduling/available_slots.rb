module Scheduling
  class AvailableSlots
    def initialize (schedule)
        @schedule = schedule
    end
    # schedule_assignerから呼ばれる
    # groupから先生を割り出し、先生のidを取得する
    def call(group)
        teacher_ids = group.map do |g|
            room_type = g[:type] == :support ? "support" : "normal"
            g[:child].class_rooms.where(room_type: room_type).first&.teacher_id
        end .compact
        # 2026年度・先生のid・slotが面談可の状態・slotが割り当てられていない状態
        MeetingSlot.where(schedule: @schedule)
                   .where(teacher_id: teacher_ids)
                   .where(status: :available)  # availableなslotに絞る(教師の面談不可への対応：status対応)
                   .where.not(id: Assignment.select(:meeting_slot_id))
    end
  end
end
