require "rails_helper"

RSpec.describe "Api::V1::Schedule", type: :request do
  describe "POST api_v1_schedule_path" do
    let(:schedule) { create(:schedule) }
    subject { post(api_v1_schedule_path(schedule.id), headers: headers) }

    context "未ログインの場合" do
    let(:headers) { {} }
    it_behaves_like "未ログインだと401が返る"
    end

    context "adminでログインしている場合" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user)  }
       it "200が返る" do
        subject
       expect(response).to have_http_status(:ok)
       end
      end

    context "teacherでログインしている場合" do
      let(:teacher_user) { create(:user, role: "teacher") }
      let(:headers) { auth_headers_for(teacher_user)  }
       it "200が返る" do
        subject
       expect(response).to have_http_status(:ok)
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
