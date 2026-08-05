require "rails_helper"

RSpec.describe Scheduling::GroupChildren do
 describe "#call" do
    let(:schedule) { create(:schedule) }
    let(:children) {Child}
    subject { Scheduling::GroupChildren.new(schedule,children).call }

    context "一人っ子かつ支援級なしの場合" do
        before do
            create(:child, schedule: schedule)
        end
        it "normalだけが登録される" do
            expect(subject.length).to eq 1
            expect(subject[0].length).to eq 1
            expect(subject[0][0][:type]).to eq :normal
        end
    end
    context "一人っ子かつ支援級ありの場合" do
        before do
            child=create(:child, schedule: schedule)
            class_room=create(:class_room, room_type: "support")
            child.class_rooms<<class_room
        end
        it "一人っ子かつsupport" do
        expect(subject.length).to eq 1
        expect(subject[0].length).to eq 2
        expect(subject[0][0][:type]).to eq :normal
        expect(subject[0][1][:type]).to eq :support
        end
    end
    context "兄弟が複数いる場合" do
        let (:family) { create(:family) }

        before do
            create(:child, schedule: schedule, family: family)
            create(:child, schedule: schedule, family: family)
        end
        it "兄弟かつnormal" do
            expect(subject.length). to eq 1
            expect(subject[0].length).to eq 2
            expect(subject[0][0][:type]).to eq :normal
            expect(subject[0][1][:type]).to eq :normal
        end

        context "支援学級の子がいる場合" do
            before do
                support_child=schedule.children.first
                class_room=create(:class_room, room_type: "support")
                support_child.class_rooms<<class_room
            end
        it "兄弟かつsuppotも含む" do
        expect(subject.length). to eq 1
        expect(subject[0].length).to eq 3
        expect(subject[0][0][:type]).to eq :normal
        expect(subject[0][1][:type]).to eq :normal
        expect(subject[0][2][:type]).to eq :support
        end
        end
    end
 end
end
