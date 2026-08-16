module Scheduling
  class SupportFilter
    SLOT_INTERVAL_MINUTES = 15

    def call(slots, group)
      return slots unless support_group?(group)
      # 特別支援学級に在籍する児童がいるグループから、特別支援学級の担任の先生を割り出す
      support_entry = group.find { |g| g[:type] == :support }
      support_teacher_id = support_entry[:child].class_rooms
                                                .where(room_type: "support")
                                                .first&.teacher_id
      return slots if support_teacher_id.nil?
      # 特別支援学級に在籍するグループから、通常学級の担任の先生を割り出す
      normal_teacher_id = support_entry[:child].class_rooms
                                               .where(room_type: "normal")
                                               .first&.teacher_id
      # 通常学級の先生のslotsを割り出し、空なら返す
      normal_slots = slots.select { |s| s.teacher_id == normal_teacher_id }
      return slots if normal_slots.empty?
      # 通常学級の先生のslotsと特別支援の先生のslotsが連続になるところを探す
      normal_slots.each do |normal_slot|
      support_slot = slots.find { |s|
      s.teacher_id == support_teacher_id &&
      consecutive?(normal_slot, s)
      }
      next unless support_slot
      # 兄弟がいる場合に困らないよう、特別支援の児童が使う2つのslot以外を、候補として残しておく
      sibling_slots = slots.reject { |s| s.id == normal_slot.id || s.id == support_slot.id }
        return [ normal_slot, support_slot ] + sibling_slots
      end
      []
    end

    private

    def support_group?(group)
      group.any? { |g| g[:type] == :support }
    end

    def consecutive?(slot1, slot2)
      slot2.start_at == slot1.start_at + SLOT_INTERVAL_MINUTES * 60 ||
slot1.start_at == slot2.start_at + SLOT_INTERVAL_MINUTES * 60
    end
  end
end
