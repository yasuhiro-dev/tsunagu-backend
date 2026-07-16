require "rails_helper"

RSpec.describe "Api::V1::ClassRoom", type: :request do
  describe "GET api_v1_class_rooms_path" do
    subject { get(api_v1_class_rooms_path, headers: headers) }

    context "未ログインの場合" do
    let(:headers) { {} }
    it_behaves_like "未ログインだと200が返る"
    end
  end
end
