require "rails_helper"

RSpec.describe "Api::V1::Admin", type: :request do
  describe "GET api/v1/admin" do
    subject { get(api_v1_admin_users_path) }
    it_behaves_like "未ログインだと401が返る"
  end
  describe "POST api/v1/admin_teachers" do
    subject { post(api_v1_admin_teachers_path) }
    it_behaves_like "未ログインだと401が返る"
  end
  describe "POST api/v1/admin_parents" do
    subject { post(api_v1_admin_parents_path) }
    it_behaves_like "未ログインだと401が返る"
  end
  describe "DELETE api/v1/admin_parents_bulk_destroy_path" do
    subject { delete(api_v1_admin_parents_bulk_destroy_path) }
    it_behaves_like "未ログインだと401が返る"
  end
  describe "DELETE api/v1/admin_teachers_bulk_destroy_path" do
    subject { delete(api_v1_admin_teachers_bulk_destroy_path) }
    it_behaves_like "未ログインだと401が返る"
  end
  describe "DELETE api/v1/admin_teachers_destroy" do
    let(:user) { create(:user) }
    subject { delete(api_v1_admin_teachers_destroy_path(user.id)) }
    it_behaves_like "未ログインだと401が返る"
  end
  describe "DELETE api/v1/admin_parents_destroy" do
    let(:user) { create(:user) }
    subject { delete(api_v1_admin_parents_destroy_path(user.id)) }
    it_behaves_like "未ログインだと401が返る"
  end
  describe "GET api/v1/admin_parents_show" do
    let(:user) { create(:user) }
    subject { get(api_v1_admin_parents_show_path(user.id)) }
    it_behaves_like "未ログインだと401が返る"
  end
  describe "PATCH api/v1/admin_parents_update" do
    let(:user) { create(:user) }
    subject { patch(api_v1_admin_parents_update_path(user.id)) }
    it_behaves_like "未ログインだと401が返る"
  end
  describe "PATCH api/v1/admin_teachers_update" do
    let(:user) { create(:user) }
    subject { patch(api_v1_admin_teachers_update_path(user.id)) }
    it_behaves_like "未ログインだと401が返る"
  end
end
