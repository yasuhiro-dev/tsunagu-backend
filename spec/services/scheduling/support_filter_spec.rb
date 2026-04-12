RSpec.describe Scheduling::SupportFilter do
    describe "#call" do
    context "特別支援でない場合" do
        let(:family_a) { create(:family) }
        let(:child_a1) { create(:child, family: family_a) }
        let(:group) { [ { child: child_a1, type: :normal } ] }
        let(:slot_1) { create(:meeting_slot) }
        let(:slots)  { [ slot_1 ] }

        subject { Scheduling::SupportFilter.new.call(slots, group) }

        it "そのままslotを返す" do
            expect(subject).to eq slots
        end
    end

    context "特別支援の担任のteacher_idがない場合" do
        let(:family_b) { create(:family) }
        let(:child_b1) { create(:child, family: family_b) }
        let(:group) { [ { child: child_b1, type: :support } ] }
        let(:slot_1) { create(:meeting_slot) }
        let(:slots)  { [ slot_1 ] }

        subject { Scheduling::SupportFilter.new.call(slots, group) }

        it "そのままslotを返す" do
            expect(subject).to eq slots
        end
    end

    context "面談の枠が空の場合" do
        let(:teacher_a) { create(:teacher) }
        let(:family_b) { create(:family) }
        let(:class_rooms) { create(:class_room, teacher: teacher_a, room_type: :support) }
        let(:child_b1) { create(:child, class_rooms: [ class_rooms ], family: family_b) }
        let(:group) { [ { child: child_b1, type: :support } ] }
        let(:slot_1) { create(:meeting_slot) }
        let(:slots)  { [ slot_1 ] }

        subject { Scheduling::SupportFilter.new.call(slots, group) }

        it "slotsを返す" do
            expect(subject).to eq slots
        end
    end

    context "特別支援の担任かつ特別支援の面談の枠に入った場合" do
        let(:family_b) { create(:family) }
        let(:teacher_a) { create(:teacher) }
        let(:teacher_b) { create(:teacher) }
        let(:normal_class_room) { create(:class_room, teacher: teacher_a, room_type: :normal) }
        let(:support_class_room) { create(:class_room, teacher: teacher_b, room_type: :support) }
        let(:child_b1) { create(:child, family: family_b, class_rooms: [ normal_class_room, support_class_room ]) }
        let(:group) { [ { child: child_b1, type: :support } ] }
        let(:schedule) { create(:schedule) }
        let(:normal_slot) { create(:meeting_slot, teacher: teacher_a, schedule: schedule) }
        let(:support_slot) { create(:meeting_slot, teacher: teacher_b, schedule: schedule) }
        let(:slots) { [ normal_slot, support_slot ] }

        subject { Scheduling::SupportFilter.new.call(slots, group) }

        it "通常学級の面談枠＋特別支援の面談枠を返す" do
            expect(subject).to eq [ normal_slot, support_slot ]
        end
    end
end
end
