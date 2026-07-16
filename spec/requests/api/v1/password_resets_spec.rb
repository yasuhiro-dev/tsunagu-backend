require "rails_helper"

RSpec.describe "Api::V1::PasswordResets", type: :request do
  describe "POST api_v1_password_resets_path" do
    let(:user) { create(:user) }
    subject { post(api_v1_password_resets_path, params: { password_reset: { email: user.email_address } }, headers: headers) }
    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "成功する", :ok
    end
  end

  describe "PATCH api_v1_password_resets_token_path" do
    let(:user) { create(:user) }
    before { user.create_reset_digest }
    subject { patch(api_v1_password_resets_token_path(user.reset_token), params: { user: { password: "newpassword123", password_confirmation: "newpassword123" } }, headers: headers) }
    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "成功する", :ok
    end
  end
end
