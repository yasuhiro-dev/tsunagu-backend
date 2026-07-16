require "rails_helper"

RSpec.describe "Api::V1::Sessions", type: :request do
  describe "POST api_v1_login_path" do
    let(:user) { create(:user) }
    subject { post(api_v1_login_path, params: { email_address: user.email_address, password: "password123" }, headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "成功する", :ok
    end
  end
end
