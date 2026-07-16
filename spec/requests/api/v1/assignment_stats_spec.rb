require "rails_helper"

RSpec.describe "Api::V1::AssignmentStats", type: :request do
  describe "GET api/v1/assignment_stats" do
    subject { get(api_v1_assignment_stats_path, headers: headers) }

    context "未ログインの場合" do
    let(:headers) { {} }
    it_behaves_like "未ログインだと401が返る"
    end

    context "adminでログインしている場合" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user)  }

       it "200が返り、割当率が含まれる" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res.keys).to include("class_rates", "all_rates")
       end
      end

    context "adminではない場合(teacher)" do
      let(:teacher) { create(:user, role: "teacher") }
      let(:headers) { auth_headers_for(teacher)  }

    it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
       end
      end
  end
end
