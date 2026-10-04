require "rails_helper"

RSpec.describe AssignmentNotifier do
  describe "#unnotified_assignment" do
    subject { described_class.new.unnotified_assignment }

    context "通知済みと未通知が両方ある場合" do
      let!(:notified) { create(:assignment) } # 通知済用
      let!(:un_notified) { create(:assignment) } # 未通知用
      # 通知済みにする
      let!(:notified_assignment) do
            create(:assignment_notification,
            child: notified.child,
            meeting_slot: notified.meeting_slot)
      end
      it "未通知のものを返す" do
        expect(subject).to eq([ un_notified ])
      end
    end
  end

  describe "#call" do
    subject { described_class.new.call }
    context "dry_run が true の場合" do
      let!(:unnotified) { create(:assignment) } # 未通知記録
      it "メールは送らず、通知記録だけ作る" do
        expect { described_class.new.call(dry_run: true) }.to change(AssignmentNotification, :count).by(1)
      end
    end

    context "dry_run が false で、送信に成功する場合" do
      let!(:unnotified) { create(:assignment) } # 未通知　関連（教師A:userなし）
      let!(:user) { create(:user, role: "teacher") }
      before { unnotified.meeting_slot.teacher.update!(user: user) }
      let(:gmail) { instance_double(GmailService, send_email: true) }   # instance_double()「送ったことにする」偽物
      before { allow(GmailService).to receive(:new).and_return(gmail) } # GmailService.newをしたときだけ偽物(gmail)を返すようにする
      it "メールを送り、通知記録を作る" do
        expect { described_class.new.call(dry_run: false) }.to change(AssignmentNotification, :count).by(1)
      end
    end
    context "dry_run が false で、Gmail通信エラーが起きる場合" do
      let!(:unnotified) { create(:assignment) } # 未通知　関連（教師A:userなし）
      let!(:user) { create(:user, role: "teacher") }
      before { unnotified.meeting_slot.teacher.update!(user: user) }
      let(:gmail) { instance_double(GmailService, send_email: true) }  # GmailServiceの形で偽物を作る。呼ばれたらtrueを返す（メールを送信したことにする）
      before { allow(GmailService).to receive(:new).and_return(gmail) }    # GmailService.newをしたときだけ、gmailの処理をする
      before { allow(gmail).to receive(:send_email).and_raise(Faraday::Error) } # gmailのsend_emailが呼ばれたら、エラーを起こす
      it "例外が呼び出し元へ出て、通知記録は作られない" do
        expect { described_class.new.call(dry_run: false) }.to raise_error(Faraday::Error) # 例外の確認
        expect(AssignmentNotification.count).to eq(0) # 通知を作っていないか確認
      end
    end
    context "dry_run が false で、予期しないエラーが起きる場合" do
      let!(:unnotified) { create(:assignment) } # 未通知　関連（教師A:userなし）
      let!(:user) { create(:user, role: "teacher") }
      before { unnotified.meeting_slot.teacher.update!(user: user) }
      let(:gmail) { instance_double(GmailService, send_email: true) }
      before { allow(GmailService).to receive(:new).and_return(gmail) }
      before { allow(gmail).to receive(:send_email).and_raise(StandardError) }
      it "例外は出ず、通知記録も作られない" do
        expect { described_class.new.call(dry_run: false) }.not_to raise_error
        expect(gmail).to have_received(:send_email)
        expect(AssignmentNotification.count).to eq(0) # 通知を作っていないか確認
      end
    end
    end

    describe "#unnotified_assignment_count" do
    subject { described_class.new.unnotified_assignment_count }
    context "未送信ユーザーが0の場合" do
      it "0を返す" do
        expect(subject).to eq(0)
      end
    end
    end
    describe "#notified_count" do
    subject { described_class.new.notified_count }
    let!(:notified) { create(:assignment) }
    let!(:assignment_notification) do
        create(:assignment_notification,
         meeting_slot: notified.meeting_slot,
          child: notified.child)
    end
    context "送信済ユーザーの数が呼ばれた場合" do
      it "全体-未通知ユーザー=送信済ユーザーを返す" do
        expect(subject).to eq(1)
      end
    end
    context "通知後に面談枠を入れ替えた場合" do
    before do
      notified.update!(meeting_slot: create(:meeting_slot)) # 新しい枠(通知記録の組と一致しない)
    end

    it "入れ替えた面談は、未通知に戻る" do
      expect(subject).to eq(0)
    end
    end
    end
    describe "#all_user_count" do
    subject { described_class.new.all_user_count }
    let!(:unnotified) { create(:assignment) } # 未通知ユーザー
    let!(:notified) { create(:assignment) } # 通知済みのユーザー
    let!(:assignment_notification) do
        create(:assignment_notification,
         meeting_slot: notified.meeting_slot,
          child: notified.child)
    end
    context "全ユーザー数を呼ばれた場合" do
      it "割り当て済みの面談の総数を返す" do
        expect(subject).to eq(2)
      end
    end
    context "通知後に面談枠を入れ替えた場合" do
    before do
      notified.update!(meeting_slot: create(:meeting_slot)) # 新しい枠(通知記録の組と一致しない)
    end

    it "履歴が残っていても、割り当ての総数のまま" do
      expect(subject).to eq(2)
    end
    end
    end
    describe "#unnotified_details" do
    subject { described_class.new.unnotified_details }
    let!(:unnotified) { create(:assignment) } # 未通知ユーザー(教師A、児童、保護者の情報を取得)
    let!(:user) { create(:user, role: "teacher") }
    let!(:class_room) { create(:class_room, teacher: unnotified.meeting_slot.teacher) }
    before { unnotified.meeting_slot.teacher.update!(user: user) } # userと教師Aをつなげる
    context "未送信ユーザーの情報が呼ばれた場合" do
      it "保護者名、児童名、先生の名前、クラス名を返す" do
        expect(subject).to eq(
          [ {
            parent_name: unnotified.child.family.name,
            child_name: unnotified.child.name,
            teacher_name: unnotified.meeting_slot.teacher.name,
            class_name: class_room.classname
          } ]
        )
      end
    end
    end
end
