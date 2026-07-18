require "rails_helper"

RSpec.describe "Api::V1::Assignments", type: :request do
  describe "POST api/v1/assignments" do
    let(:child) { create(:child) }
    let(:meeting_slot) { create(:meeting_slot) }
    subject { post(api_v1_assignments_path, headers: headers, params: { meeting_slot_id: meeting_slot.id, child_id: child.id }) }

    context "未ログインの場合" do
    let(:headers) { {} }
    it_behaves_like "未ログインだと401が返る"
    end

    context "adminでログインしている場合" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }
       it "200が返り、割り当てされたデータが含まれる" do
        subject
        puts response.body
        expect(response).to have_http_status(:created)
        res = JSON.parse(response.body)
        expect(res.keys).to include("meeting_slot_id", "child_id")
       end
      end

    context "teacherでログインしている場合" do
      let(:teacher_user) { create(:user, role: "teacher") }
      let(:headers) { auth_headers_for(teacher_user)  }

       it "200が返り、割り当てされたデータが含まれる" do
        subject
        expect(response).to have_http_status(:created)
        res = JSON.parse(response.body)
        expect(res.keys).to include("child_id", "meeting_slot_id")
       end
      end

    context "admin/teacherではない場合(parent)" do
      let(:parent) { create(:user, role: "parent") }
      let(:headers) { auth_headers_for(parent)  }

    it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
       end
      end
  end
end
