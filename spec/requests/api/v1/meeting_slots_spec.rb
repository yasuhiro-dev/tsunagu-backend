require "rails_helper"

RSpec.describe "Api::V1::MeetingSlots", type: :request do
  # def index
  describe "GET api_v1_meeting_slots_path" do
    subject { get(api_v1_meeting_slots_path, headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "teacherでログインしている場合" do
      let(:teacher) { create(:teacher) }
      let(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let(:headers) { auth_headers_for(teacher_user) }
      let!(:meeting_slot) { create(:meeting_slot, teacher: teacher) }
      let!(:child) { create(:child) }
      let!(:assignment) { create(:assignment, meeting_slot: meeting_slot, child: child) }

      it "200が返り、担当するmeeting_slotの情報が渡る" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res.first.keys).to include("id", "start_at", "end_at", "status", "child_name")
      end
    end

    context "parentでログインしている場合" do
      let(:family) { create(:family) }
      let(:parent_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(parent_user) }
      let!(:child) { create(:child, family: family) }
      let(:teacher) { create(:teacher) }
      let!(:class_room) { create(:class_room, teacher: teacher) }
      let(:meeting_slot) { create(:meeting_slot, teacher: teacher) }
      let!(:assignment) { create(:assignment, meeting_slot: meeting_slot, child: child) }

      it "200が返り、meeting_slotの情報が渡る" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res.first.keys).to include("id", "child_name", "class_name", "start_at", "end_at")
      end
    end

    context "parent/teacherではない場合(admin)" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }

      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def all
  describe "GET api_v1_AllMeetingSlots" do
    subject { get(api_v1_all_meeting_slots_path, headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "parentでログインしている場合" do
      let(:family) { create(:family) }
      let(:parent_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(parent_user) }
      let!(:child) { create(:child, family: family) }
      let(:teacher) { create(:teacher) }
      let!(:class_room) { create(:class_room, teacher: teacher) }
      let(:meeting_slot) { create(:meeting_slot, teacher: teacher) }
      let!(:assignment) { create(:assignment, meeting_slot: meeting_slot, child: child) }

      before do
        child.class_rooms << class_room
      end

      it "200が返り、meeting_slotの情報が渡る" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res.first.keys).to include("id", "start_at", "end_at", "status", "child_name")
      end
    end

    context "parentではない場合(admin)" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }

      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "parentではない場合(teacher)" do
      let(:teacher_user) { create(:user, role: "teacher") }
      let(:headers) { auth_headers_for(teacher_user) }

      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
