require "rails_helper"

RSpec.describe "Api::V1::TeachersController", type: :request do
    describe "GET api/v1/teachers" do
        subject { get(api_v1_teachers_capacity_path, headers: headers) }

        context "ログイン中の教師の場合" do
            let!(:user) { create(:user, role: "teacher") } # userを作成すると教師も作られる
            let!(:headers) { auth_headers_for(user) }
            let!(:class_room) { create(:class_room, teacher: user.teacher) } # そのuserに教師を紐付ける
            let!(:child)      { create(:child) }
            let!(:child_class_room) { create(:child_class_room, child: child, class_room: class_room) }

            it "その教師が担当しているクラスの児童数を返す" do
            subject
            res = JSON.parse(response.body)
            expect(res).to eq({ "children_count" => 1 })
            end
        end
    end
end
