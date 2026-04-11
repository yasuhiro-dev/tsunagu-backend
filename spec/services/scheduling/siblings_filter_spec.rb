RSpec.describe Scheduling::SiblingsFilter do
  describe "#call" do
    subject { Scheduling::SiblingsFilter.new.call(slots, group) }

    let(:family_a) { create(:family) }
    let(:child_a1) { create(:child, family: family_a) }
    let(:slot1) { create(:meeting_slot) }
    let(:slots) { [ slot1 ] }
    let(:group) { [ { child: child_a1, type: :normal } ] }

    context "兄弟でない場合" do
      it "そのままのslotを返す" do
        expect(subject).to eq slots
      end
    end

    context "兄弟かつ連続の場合" do
      let(:child_b1) { create(:child, family: family_a) }
      let(:child_b2) { create(:child, family: family_a) }
      let(:slot2) { create(:meeting_slot, start_at: slot1.start_at + 15.minutes) }
      let(:slots) { [ slot1, slot2 ] }
      let(:group) do
        [
          { child: child_b1, type: :normal },
          { child: child_b2, type: :normal }
        ]
      end

      before do
        child_b1.class_rooms << create(:class_room, room_type: 0, teacher: slot1.teacher)
        child_b2.class_rooms << create(:class_room, room_type: 0, teacher: slot2.teacher)
      end

      it "１５分間隔で連続に割り当て" do
        expect(subject).to eq [ slot1, slot2 ]
      end
    end

    context "兄弟だけど連続でない場合" do
      let(:child_b1) { create(:child, family: family_a) }
      let(:child_b2) { create(:child, family: family_a) }
      let(:slot3) { create(:meeting_slot, start_at: slot1.start_at + 30.minutes) }
      let(:slots) { [ slot1, slot3 ] }
      let(:group) do
        [
          { child: child_b1, type: :normal },
          { child: child_b2, type: :normal }
        ]
      end

      before do
        child_b1.class_rooms << create(:class_room, room_type: 0, teacher: slot1.teacher)
        child_b2.class_rooms << create(:class_room, room_type: 0, teacher: slot3.teacher)
      end

      it "空のslotを返す" do
        expect(subject).to eq []
      end
    end
  end
end
