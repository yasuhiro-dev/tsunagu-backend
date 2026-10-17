require "rails_helper"

RSpec.describe "Api::V1::Demo", type: :request do
  describe "POST api/v1/demo/reset" do
    subject { post(api_v1_demo_reset_path, headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "デモアカウントではない場合" do
      let(:admin) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin) }
      let!(:assignment) { create(:assignment) }

      it "403が返り、データは変更されない" do
        expect { subject }.not_to change(Assignment, :count)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "デモアカウントの場合" do
      let(:demo_teacher_user) { create(:user, role: "teacher", email_address: "aoki@example.com") }
      let(:demo_parent_user) { create(:user, role: "parent", email_address: "parent-nonsubmit@example.com") }
      let(:demo_family) { demo_parent_user.family }
      let(:headers) { auth_headers_for(demo_teacher_user) }

      # デモを一度最後まで体験した後の状態を作る
      let!(:reserved_slot) { create(:meeting_slot, status: :reserved) }
      let!(:assignment) { create(:assignment, meeting_slot: reserved_slot) }
      let!(:notification) { create(:assignment_notification, child: assignment.child, meeting_slot: reserved_slot) }
      let!(:demo_blocked_slot) { create(:meeting_slot, teacher: demo_teacher_user.teacher, status: :blocked) }
      let!(:demo_availability) { create(:family_availability, family: demo_family) }

      # デモで操作できない人のデータ
      let!(:other_blocked_slot) { create(:meeting_slot, status: :blocked) }
      let(:other_family) { create(:family, submitted: true) }
      let!(:other_availability) { create(:family_availability, family: other_family) }

      before { demo_family.update!(submitted: true) }

      it "200が返る" do
        subject
        expect(response).to have_http_status(:ok)
      end

      it "割り当てと通知の記録が消え、予約済みの枠が空きに戻る" do
        subject
        expect(Assignment.count).to eq(0)
        expect(AssignmentNotification.count).to eq(0)
        expect(reserved_slot.reload.status).to eq("available")
      end

      it "デモ教師の対応できない枠が空きに戻る" do
        subject
        expect(demo_blocked_slot.reload.status).to eq("available")
      end

      it "デモ保護者が未提出に戻り、選んだ日時が消える" do
        subject
        expect(demo_family.reload.submitted).to eq(false)
        expect(demo_family.family_availabilities.count).to eq(0)
      end

      context "面談日が十分に先の場合" do
        let(:schedule) { create(:schedule, year: Schedule.current_year, deadline_at: 1.day.ago) }
        let(:start_at) { 5.weeks.from_now.change(hour: 15) }
        let!(:slot) { create(:meeting_slot, schedule: schedule, start_at: start_at, end_at: start_at + 15.minutes) }

        it "面談日は動かさず、締切日を最初の面談日の2週間前に戻す" do
          subject
          expect(slot.reload.start_at).to eq(start_at)
          expect(schedule.reload.deadline_at.to_date).to eq(start_at.to_date - 2.weeks)
        end
      end

      context "面談日が近い、または過ぎている場合" do
        let(:schedule) { create(:schedule, year: Schedule.current_year, deadline_at: 3.weeks.ago) }
        let(:start_at) { 1.week.ago.change(hour: 15) }
        let!(:slot) { create(:meeting_slot, schedule: schedule, start_at: start_at, end_at: start_at + 15.minutes) }

        it "面談日を週単位で先へ送り、曜日と時刻は変えない" do
          subject
          slot.reload
          expect(slot.start_at.to_date).to be >= Date.current + 4.weeks
          expect(slot.start_at.to_date).to be < Date.current + 5.weeks
          expect(slot.start_at.wday).to eq(start_at.wday)
          expect(slot.start_at.hour).to eq(15)
          expect(slot.end_at - slot.start_at).to eq(15.minutes)
        end

        it "締切日が今日より先になる" do
          subject
          expect(schedule.reload.deadline_at.to_date).to eq(slot.reload.start_at.to_date - 2.weeks)
          expect(schedule.deadline_at).to be > Time.current
        end
      end

      it "デモで操作できない教師・保護者のデータは変更されない" do
        subject
        expect(other_blocked_slot.reload.status).to eq("blocked")
        expect(other_family.reload.submitted).to eq(true)
        expect(other_family.family_availabilities.count).to eq(1)
      end
    end
  end
end
