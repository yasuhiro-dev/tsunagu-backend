require "rails_helper"

RSpec.describe "Api::V1::UsersParent", type: :request do
  describe "POST api_v1_users_parent_path" do
    let(:class_room) { create(:class_room) }
    subject { post(api_v1_users_parent_path,
    params: { user: { email_address: "parent_test@example.com",
    password: "password123" },
    family_name: "test",
    children: [
      { name: "test",
    class_room_id: class_room.id }
    ]
    }) }
    it_behaves_like "成功する", :created
  end
end
