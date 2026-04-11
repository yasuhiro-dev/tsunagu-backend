require "rails_helper"

RSpec.describe Scheduling::PrioritySort do
    describe "#call" do
    subject { Scheduling::PrioritySort.new.call(groups) }

    let(:family_a) { create(:family) }
    let(:family_b) { create(:family) }
    let(:child_a1) { create(:child, family: family_a) }
    let(:child_a2) { create(:child, family: family_a) }
    let(:child_b1) { create(:child, family: family_b) }

    let(:groups) do
    [
        [ { child: child_b1, type: :normal } ],
        [ { child: child_a1, type: :normal }, { child: child_a2, type: :normal } ]
    ]
    end

    context "兄弟であれば" do
        it "先頭に来る" do
          expect(subject.first).to eq groups[1]
        end
    end

    context "支援学級であれば" do
    let(:groups) do
    [
        [ { child: child_a1, type: :normal } ],
        [ { child: child_a2, type: :normal },
        { child: child_b1, type: :support } ]
    ]
    end
        it "先頭に来る" do
          expect(subject.first).to eq groups[1]
    end
    end
    context "時間の制約があれば" do
      let(:groups) do
      [
        [ { child: child_a1, type: :normal } ],
        [ { child: child_b1, type: :normal } ]
      ]
      end
      before do
        create(:family_unavailability, family: child_b1.family)
      end
      it "先頭に来る" do
        expect(subject.first).to eq groups[1]
      end
    end
    context "複数条件が重なる場合" do
        let(:groups) do
            [
                [ { child: child_a1, type: :normal }, { child: child_a2, type: :normal } ],
                [ { child: child_b1, type: :normal } ]
            ]
        end
        before do
            create(:family_unavailability, family: child_a1.family)
        end
        it "先頭に来る" do
            expect(subject.first). to eq groups[0]
        end
    end
end
end
