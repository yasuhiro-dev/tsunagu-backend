RSpec.describe Scheduling::TimeFilter do
  describe "#call" do
    let(:family_a) { create(:family, submitted: true) }
    let(:child_a1) { create(:child, family: family_a) }
    let(:group) { [ { child: child_a1 } ] }
    let(:meeting_slot1) { create(:meeting_slot) }
    let(:meeting_slot2) { create(:meeting_slot, start_at: meeting_slot1.start_at + 15.minutes) }
    let(:slots) { [ meeting_slot1, meeting_slot2 ] }

    subject { Scheduling::TimeFilter.new.call(slots, group) }

    context "参加できる時刻を提出している場合" do
      let!(:availability) { create(:family_availability, family: family_a, meeting_slot: meeting_slot1) }
      it "参加できる時刻のslotだけを返す" do
        expect(subject).to eq [ meeting_slot1 ]
      end
    end

    context "未提出の場合" do
      let(:family_a) { create(:family, submitted: false) }
      let!(:availability) { create(:family_availability, family: family_a, meeting_slot: meeting_slot1) }
      it "途中の入力は使わず、slotをそのまま返す" do
        expect(subject).to eq slots
      end
    end

    context "別の担任の、同じ時刻の枠がある場合" do
      # meeting_slot factory は teacher を都度作るので、別の担任になる
      let(:other_teacher_slot) { create(:meeting_slot, start_at: meeting_slot1.start_at) }
      let(:slots) { [ meeting_slot1, other_teacher_slot, meeting_slot2 ] }
      let!(:availability) { create(:family_availability, family: family_a, meeting_slot: meeting_slot1) }

      it "保護者の回答は時刻に対する制約なので、別の担任の同じ時刻の枠も残る" do
        expect(subject).to eq [ meeting_slot1, other_teacher_slot ]
      end
    end
  end
end
