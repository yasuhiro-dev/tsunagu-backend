require "rails_helper"

RSpec.describe "Api::V1::Families", type: :request do
  describe "GET api_v1_family_path" do
    let(:family) { create(:family) }
    subject { get(api_v1_family_path(family.id), headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "teacherでログインしている場合" do
      # 現在ログイン中のteacherを作り、headersへ
      let(:teacher_user) { create(:user, role: "teacher") }
      let(:headers) { auth_headers_for(teacher_user) }
    it "200が返り、familyの情報が渡る" do
    subject
    expect(response).to have_http_status(:ok)
    res = JSON.parse(response.body)
    expect(res.keys).to include("submitted")
      end
    end
  end
end
