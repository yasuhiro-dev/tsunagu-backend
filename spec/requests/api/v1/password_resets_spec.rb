require "rails_helper"

# PasswordResetsに関するテスト（リクエストスペック）
RSpec.describe "Api::V1::PasswordResets", type: :request do

  # POSTメソッドのテスト
  describe "POST api_v1_password_resets_path" do
    let(:user) { create(:user) }
    # コントローラーの create アクションへ、登録済みのuserのメールアドレスを送る
    subject { post(api_v1_password_resets_path, params: { password_reset: { email: user.email_address } }) }
    context "メールアドレスが一致していたら" do
      # 外側の let(:user) をそのまま使う
      it_behaves_like "成功する", :ok
    end
    context "トークン生成に失敗する場合" do
      before { user.update_column(:role, nil) }
      it_behaves_like "成功する", :unprocessable_entity
    end
    context "メールアドレスが一致していない場合" do
      subject { post(api_v1_password_resets_path, params: { password_reset: { email: "notfound@example.com" } }) }
      it_behaves_like "成功する", :not_found
    end
  end

  # PATCHメソッドのテスト
  describe "PATCH api_v1_password_resets_token_path" do
    let(:user) { create(:user) }
    # userのリセットトークンを作成する。
    before { user.create_reset_digest }
    # userのリセットトークンとpasswordを一緒に持たせる
    subject { patch(api_v1_password_resets_token_path(user.reset_token), params: { user: { password: "newpassword123", password_confirmation: "newpassword123" } }) }
    
    context "DBに保存されたreset_digestと一致するUserがあれば" do
      # 外側の let(:user) をそのまま使う
      it_behaves_like "成功する", :ok
    end
    context "DBに保存されたreset_digestと一致するUserがなければ" do
      subject { patch(api_v1_password_resets_token_path("nottoken"), params: { user: { password: "newpassword123", password_confirmation: "newpassword123" } }) }
      it_behaves_like "成功する", :not_found
    end
  
    context "トークンの有効期限が切れていなければ" do
      # 外側の before { user.create_reset_digest }をそのまま使う
      it_behaves_like "成功する", :ok
    end

    context "トークンの有効期限が切れていれば" do
      before { user.update_column(:reset_sent_at,3.hours.ago) }
      it_behaves_like "成功する", :unprocessable_entity 
    end
    
    context "パスワードが空だったら" do
      subject { patch(api_v1_password_resets_token_path(user.reset_token), params: { user: { password: "", password_confirmation: "" } }) }
      it_behaves_like "成功する", :unprocessable_entity 
    end

    context "パスワードがバリデーションエラーだったら" do
      subject { patch(api_v1_password_resets_token_path(user.reset_token), params: { user: { password: "1234", password_confirmation: "1234" } }) }
      it_behaves_like "成功する", :unprocessable_entity 
    end
  end
end
