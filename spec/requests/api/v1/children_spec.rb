require "rails_helper"

RSpec.describe "Api::V1::Children", type: :request do
  describe "GET api_v1_children_unassigned_path" do
    subject { get(api_v1_children_unassigned_path) }
    it_behaves_like "未ログインだと401が返る"
  end

  describe "GET api_v1_child_list_path" do
    subject { get(api_v1_child_list_path) }
    it_behaves_like "未ログインだと401が返る"
  end
end
