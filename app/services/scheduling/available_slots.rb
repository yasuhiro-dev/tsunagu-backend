module Scheduling
  class AvailableSlots
    def initialize (schedule)
        @schedule = schedule
    end
    # schedule_assignerから呼ばれる
    # groupから先生を割り出し、その先生のslotに絞る
    def call(group)
        teacher_ids = group.map do |g|
            room_type = g[:type] == :support ? "support" : "normal"
            g[:child].class_rooms.detect { |cr| cr.room_type == room_type }&.teacher_id
        end .compact
        # 割り当て済みのslotはAssignerがstatusをreservedに書き換えるので、ここで弾ける
        all_slots.select { |s| teacher_ids.include?(s.teacher_id) && s.status == "available" }
    end

    private

    # 全slotの取得はグループをまたいで1回だけ。
    # グループごとにDBを引くとN+1になり、割り当てが進むほどサブクエリも重くなるため。
    def all_slots
        @all_slots ||= MeetingSlot.where(schedule: @schedule)
                                  .where(status: :available)  # availableなslotに絞る(教師の面談不可への対応：status対応)
                                  .where.not(id: Assignment.select(:meeting_slot_id))
                                  .to_a
    end
  end
end
