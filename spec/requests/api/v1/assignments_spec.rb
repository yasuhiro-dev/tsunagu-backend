require "rails_helper"

RSpec.describe "Api::V1::Assignments", type: :request do
  describe "POST api/v1/assignments" do
    subject { post(api_v1_assignments_path) }

    it_behaves_like "未ログインだと401が返る"
    end
end
