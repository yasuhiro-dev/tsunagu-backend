require "rails_helper"

RSpec.describe "Api::V1::FamilyUnavailabilities", type: :request do
  describe "GET api_v1_family_unavailabilities_path" do
    subject { get(api_v1_family_unavailabilities_path) }
    it_behaves_like "未ログインだと401が返る"
  end
  describe "POST api_v1_family_unavailabilities_path" do
    subject { post(api_v1_family_unavailabilities_path) }
    it_behaves_like "未ログインだと401が返る"
  end
  describe "DELETE api_v1_family_unavailability_meeting_slot_path" do
    let(:meeting_slot) { create(:meeting_slot) }
    subject { delete(api_v1_family_unavailability_meeting_slot_path(meeting_slot.id)) }
    it_behaves_like "未ログインだと401が返る"
  end
  describe "PATCH api_v1_family_unavailability_family_path" do
    let(:family) { create(:family) }
    subject { patch(api_v1_family_unavailability_family_path(family.id)) }
    it_behaves_like "未ログインだと401が返る"
  end
end
