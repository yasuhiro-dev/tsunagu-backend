RSpec.describe Scheduling::TimeFilter do
  describe "#call" do
    let(:family_a) { create(:family) }
    let(:child_a1) { create(:child, family: family_a) }
    let(:group) { [ { child: child_a1 } ] }
    let(:meeting_slot1) { create(:meeting_slot) }
    let(:slots) { [ meeting_slot1 ] }

    subject { Scheduling::TimeFilter.new.call(slots, group) }

    context "面談不可な時間がある場合" do
    let!(:unavailability_slot) { create(:unavailability, family: family_a, meeting_slot: meeting_slot1) }
       it "そのslotを除外するして返す" do
          expect(subject).to eq []
       end
    end

    context "面談不可な時間がない場合" do
       it "slotをそのまま返す" do
          expect(subject).to eq slots
       end
    end
    context "別の担任の、同じ時刻の枠がある場合" do
  # meeting_slot factory は teacher を都度作るので、別の担任になる
  let(:other_teacher_slot) { create(:meeting_slot, start_at: meeting_slot1.start_at) }
  let(:slots) { [ meeting_slot1, other_teacher_slot ] }
  let!(:unavailability_slot) { create(:unavailability, family: family_a, meeting_slot: meeting_slot1) }

  it "保護者の不可は時刻に対する制約なので、別の担任の枠も除外される" do
    expect(subject).to eq []
  end
end
  end
end
