require "rails_helper"

RSpec.describe "Api::V1::MeetingSlots", type: :request do
  describe "GET api_v1_meeting_slots_path" do
    subject { get(api_v1_meeting_slots_path) }
    it_behaves_like "未ログインだと401が返る"
  end
  describe "GET api_v1_AllMeetingSlots" do
    subject { get(api_v1_all_meeting_slots_path) }
    it_behaves_like "未ログインだと401が返る"
  end
end
