require "rails_helper"

RSpec.describe Scheduling::Assigner do
  describe "#call" do
    it "割り当てされない児童を戻り値として返す" do
      # 準備
      child = create(:child)
      class_room = create(:class_room)

      child.class_rooms << class_room

      slot = create(:meeting_slot, teacher_id: class_room.teacher_id)

      group = [ { type: :normal, child: child } ]
      slots = []

      # 実行
      result = Scheduling::Assigner.new.call(slots, group)

      # 検証
      expect(result).to include(group.first[:child])
    end
  end
end
