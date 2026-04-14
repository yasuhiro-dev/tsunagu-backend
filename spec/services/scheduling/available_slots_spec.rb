RSpec.describe Scheduling::AvailableSlots do
  describe "#call" do
    let(:schedule)       { create(:schedule) }
    let(:child_a)        { create(:child) }
    let(:child_b)        { create(:child) }
    let(:normal_teacher) { create(:teacher) }
    let(:support_teacher) { create(:teacher) }

    let(:normal_class_room) do
      class_room = create(:class_room, teacher: normal_teacher, room_type: "normal")
      create(:child_class_room, child: child_a, class_room: class_room)
      class_room
    end

    let(:support_class_room) do
      class_room = create(:class_room, teacher: support_teacher, room_type: "support")
      create(:child_class_room, child: child_b, class_room: class_room)
      class_room
    end

    let(:normal_slot) { create(:meeting_slot, schedule: schedule, teacher: normal_teacher) }
    let(:support_slot) { create(:meeting_slot, schedule: schedule, teacher: support_teacher) }

    context "room_typeがsupportの場合" do
      let(:group) { [ { child: child_b, type: :support } ] }
      subject { Scheduling::AvailableSlots.new(schedule).call(group) }

      it "supportのslotに絞り込む" do
        support_class_room
        support_slot
        expect(subject).to eq [ support_slot ]
      end
    end

    context "room_typeがnormalの場合" do
      let(:group) { [ { child: child_a, type: :normal } ] }
      subject { Scheduling::AvailableSlots.new(schedule).call(group) }

      it "normalのslotに絞り込む" do
        normal_class_room
        normal_slot
        expect(subject).to eq [ normal_slot ]
      end
    end

    context "既にAssignmentに使われている場合" do
      let(:group) { [ { child: child_a, type: :normal } ] }
      subject { Scheduling::AvailableSlots.new(schedule).call(group) }

      it "そのslotは除外する" do
        normal_class_room
        normal_slot
        create(:assignment, meeting_slot: normal_slot)
        expect(subject).to eq []
      end
    end
  end
end
