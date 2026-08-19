RSpec.describe Scheduling::ScheduleAssigner do
  describe "#call" do
    let(:schedule) { create(:schedule) }
    let(:children) { create(:child) }
    let(:assigner) { described_class.new(schedule, children) }
    let(:group1) { [ { child: "child" } ] }
    let(:slots) { [ double("slot") ] }

    before do
    allow(Scheduling::GroupChildren).to receive_message_chain(:new, :call).and_return ([ group1 ])
    allow(Scheduling::PrioritySort).to receive_message_chain(:new, :call).and_return ([ group1 ])
    allow(Scheduling::AvailableSlots).to receive_message_chain(:new, :call).and_return(slots)
    allow(Scheduling::SiblingsFilter).to receive_message_chain(:new, :call).and_return(slots)
    allow(Scheduling::SupportFilter).to receive_message_chain(:new, :call).and_return(slots)
    allow(Scheduling::TimeFilter).to receive_message_chain(:new, :call).and_return(slots)
    allow(Scheduling::Assigner).to receive_message_chain(:new, :call).and_return ([ group1 ])
  end
    context "slotsが存在する場合" do
        it "Assignerを呼び出す" do
            assigner.call
            expect(Scheduling::Assigner).to have_received(:new)
        end
    end
    context "slotsが空の場合" do
        before do
            allow(Scheduling::TimeFilter).to receive_message_chain(:new, :call).and_return([])
            allow(Scheduling::SiblingsFilter).to receive_message_chain(:new, :call).and_return([])
            allow(Scheduling::SupportFilter).to receive_message_chain(:new, :call).and_return([])
        end
        it "Assignerを呼び出さない" do
           assigner.call
           expect(Scheduling::Assigner).not_to have_received(:new)
        end
    end
  end
end
