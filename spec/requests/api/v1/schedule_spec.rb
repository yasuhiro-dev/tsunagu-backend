require "rails_helper"

RSpec.describe "Api::V1::Schedule", type: :request do
  describe "POST api_v1_schedule_path" do
    let(:schedule) { create(:schedule) }
    subject { post(api_v1_schedule_path(schedule.id)) }
    it_behaves_like "未ログインだと401が返る"
  end
end
