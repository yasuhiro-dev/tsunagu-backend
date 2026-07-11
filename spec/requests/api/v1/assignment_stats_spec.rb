require "rails_helper"

RSpec.describe "Api::V1::AssignmentStats", type: :request do
  describe "GET api/v1/assignment_stats" do
    subject { get(api_v1_assignment_stats_path) }

    it_behaves_like "未ログインだと401が返る"
  end
end
