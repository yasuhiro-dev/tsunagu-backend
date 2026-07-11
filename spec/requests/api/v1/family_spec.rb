require "rails_helper"

RSpec.describe "Api::V1::Families", type: :request do
  describe "GET api_v1_family_path" do
    let(:family) { create(:family) }
    subject { get(api_v1_family_path(family.id)) }
    it_behaves_like "未ログインだと401が返る"
  end
end
