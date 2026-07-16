require "rails_helper"

RSpec.describe "Api::V1::FamilyUnavailabilities", type: :request do
  # def indexのテスト
  describe "GET api_v1_family_unavailabilities_path" do
    subject { get(api_v1_family_unavailabilities_path, headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "parentでログインしている場合" do
      let(:family) { create(:family) }
      let(:parent_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(parent_user) }
      let(:meeting_slot) { create(:meeting_slot) }
      let!(:family_unavailability) { create(:family_unavailability, family: family, meeting_slot: meeting_slot) }

      it "200が返り、familyの日程不可のmeeting_slotを取得する" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res).to include(meeting_slot.id)
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

    context "parentではない場合(admin)" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }

      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def createのテスト
  describe "POST api_v1_family_unavailabilities_path" do
    let(:meeting_slot) { create(:meeting_slot) }
    subject { post(api_v1_family_unavailabilities_path, params: { meeting_slot_id: meeting_slot.id }, headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "parentでログインしている場合" do
      let(:family) { create(:family) }
      let(:parent_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(parent_user) }

      it "200が返り、familyの日程不可のmeeting_slotを作成する" do
        subject
        expect(response).to have_http_status(:created)
        res = JSON.parse(response.body)
        expect(res["meeting_slot_id"]).to eq(meeting_slot.id)
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

    context "parentではない場合(admin)" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }

      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def destroyのテスト
  describe "DELETE api_v1_family_unavailability_meeting_slot_path" do
    let(:meeting_slot) { create(:meeting_slot) }
    subject { delete(api_v1_family_unavailability_meeting_slot_path(meeting_slot.id), headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "parentでログインしている場合" do
      let(:family) { create(:family) }
      let(:parent_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(parent_user) }
      let!(:family_unavailability) { create(:family_unavailability, family: family, meeting_slot: meeting_slot) }

      it "200が返り、familyの日程不可のmeeting_slotを削除する" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res["message"]).to eq("delete")
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

    context "parentではない場合(admin)" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }

      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def updateのテスト
  describe "PATCH api_v1_family_unavailability_family_path" do
    let(:family) { create(:family) }
    subject { patch(api_v1_family_unavailability_family_path(family.id), headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "すでに提出している場合" do
      let(:family) { create(:family, submitted: true) }
      let(:parent_user) { create(:user, role: "parent") }
      let(:headers) { auth_headers_for(parent_user) }

      it "403が返り、エラーメッセージが返る" do
        subject
        expect(response).to have_http_status(:forbidden)
        res = JSON.parse(response.body)
        expect(res["error"]).to eq("すでに提出されています")
      end
    end

    context "提出されていない場合" do
      let(:parent_user) { create(:user, role: "parent") }
      let(:headers) { auth_headers_for(parent_user) }

      it "200が返り、日程不可の日程が更新される" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res["message"]).to eq("提出されました")
      end
    end
  end
end
