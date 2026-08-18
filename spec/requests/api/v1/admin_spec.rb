require "rails_helper"

RSpec.describe "Api::V1::Admin", type: :request do
  # def index
  describe "GET api/v1/admin" do
    subject { get(api_v1_admin_users_path, headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "adminでログインしている場合" do
      let!(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }
      let!(:teacher_user) { create(:user, role: "teacher") }
      let!(:class_room) { create(:class_room, teacher: teacher_user.teacher) }
      let!(:family_user) { create(:user, role: "parent") }
      let!(:child) { create(:child, family: family_user.family) }
      before do
        child.class_rooms << class_room
      end
      it "200が返り、教師・保護者の情報を取得する" do
  subject

  res = JSON.parse(response.body)
  puts "作ったclass_room: id=#{class_room.id}, classname=#{class_room.classname}"
  puts "teacher_userのid: #{teacher_user.id}"
  puts "レスポンスのteachers: #{res["teachers"]}"
  expect(response).to have_http_status(:ok)
  expect(res["teachers"].first["classname"]).to eq(class_room.classname)
  expect(res["parents"].first["children_name"]).to eq(child.name)
end
    end

    context "adminではない場合(parent)" do
      let(:family) { create(:family) }
      let!(:family_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(family_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "adminではない場合(teacher)" do
      let(:teacher) { create(:teacher) }
      let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let(:headers) { auth_headers_for(teacher_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def create_teacher
  describe "POST api/v1/admin_teachers" do
    let(:teacher) { create(:teacher) }
    let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
    let(:class_room) { create(:class_room, teacher: teacher) }

    subject { post(api_v1_admin_teachers_path,
       params: {
         user: { email_address: "xxx@example.com", password: "password123" },
         name: "山田太郎",

         class_room_id: class_room.id
       },
       headers: headers)
       }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "adminでログインしている場合" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }

      it "200が返り、教師を作成する" do
        subject
        expect(response).to have_http_status(:created)
        res = JSON.parse(response.body)
        expect(res["teacher"]["class_room"]).to eq(class_room.classname)
      end
    end

    context "adminではない場合(parent)" do
      let(:family) { create(:family) }
      let!(:family_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(family_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "adminではない場合(teacher)" do
      let(:teacher) { create(:teacher) }
      let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let(:headers) { auth_headers_for(teacher_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def create_parent
  describe "POST api/v1/admin_parents" do
    let(:teacher) { create(:teacher) }
    let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
    let(:class_room) { create(:class_room, teacher: teacher) }
    subject { post(api_v1_admin_parents_path,
       params: {
         user: { email_address: "xxx@example.com", password: "password123" },
         family_name: "山田家",
         name_kana: "ヤマダケ",
         children: [
          { name: "山田太郎", class_room_id: class_room.id }
        ]
       },
       headers: headers)}

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "adminでログインしている場合" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }
      let!(:schedule) { create(:schedule) }

      it "200が返り、保護者を作成する" do
        subject
        expect(response).to have_http_status(:created)
        res = JSON.parse(response.body)
        expect(res["user"]["email_address"]).to eq("xxx@example.com")
      end
    end

    context "adminではない場合(parent)" do
      let(:family) { create(:family) }
      let!(:family_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(family_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "adminではない場合(teacher)" do
      let(:teacher) { create(:teacher) }
      let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let(:headers) { auth_headers_for(teacher_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def parents bulk_destroy
  describe "DELETE api/v1/admin_parents_bulk_destroy_path" do
    let(:parent_user1) { create(:user, role: "parent") }
    let(:parent_user2) { create(:user, role: "parent") }
    subject { delete(api_v1_admin_parents_bulk_destroy_path, params: {
      ids: [ parent_user1.id, parent_user2.id ]
      }, headers: headers)}

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "adminでログインしている場合" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }
      let!(:parent_user1) { create(:user, role: "parent") }
      let!(:parent_user2) { create(:user, role: "parent") }
      it "200が返り、指定した保護者を削除する" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res["message"]).to eq("削除しました")
      end
    end
    context "adminではない場合(parent)" do
      let(:family) { create(:family) }
      let!(:family_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(family_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "adminではない場合(teacher)" do
      let(:teacher) { create(:teacher) }
      let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let(:headers) { auth_headers_for(teacher_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def teacher_bulk_destroy
  describe "DELETE api/v1/admin_teachers_bulk_destroy_path" do
    let(:teacher_user1) { create(:user, role: "teacher") }
    let(:teacher_user2) { create(:user, role: "teacher") }
    subject { delete(api_v1_admin_teachers_bulk_destroy_path,
    params: {
      ids: [ teacher_user1.id, teacher_user2.id ]
      }, headers: headers)}

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

  context "adminでログインしている場合" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }
      let!(:teacher_user1) { create(:user, role: "teacher") }
      let!(:teacher_user2) { create(:user, role: "teacher") }
      it "200が返り、指定した教師を削除する" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res["message"]).to eq("削除しました")
      end
    end
     context "adminではない場合(parent)" do
      let(:family) { create(:family) }
      let!(:family_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(family_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "adminではない場合(teacher)" do
      let(:teacher) { create(:teacher) }
      let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let(:headers) { auth_headers_for(teacher_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def destroy(teachers)
  describe "DELETE api/v1/admin_teachers_destroy" do
    let(:user_teacher) { create(:user, role: "teacher") }
    subject { delete(api_v1_admin_teachers_destroy_path(user_teacher.id), headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "adminでログインしている場合" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }
      let!(:user_teacher) { create(:user, role: "teacher") }
      it "200が返り、指定した教師を削除する" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res["message"]).to eq("削除しました")
      end
    end

    context "adminではない場合(parent)" do
      let(:family) { create(:family) }
      let!(:family_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(family_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "adminではない場合(teacher)" do
      let(:teacher) { create(:teacher) }
      let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let(:headers) { auth_headers_for(teacher_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def destroy(parents)
  describe "DELETE api/v1/admin_parents_destroy" do
    let(:user_parent) { create(:user, role: "parent") }
    subject { delete(api_v1_admin_parents_destroy_path(user_parent.id), headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "adminでログインしている場合" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }
      let!(:user_teacher) { create(:user, role: "teacher") }
      it "200が返り、指定した教師を削除する" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res["message"]).to eq("削除しました")
      end
    end

    context "adminではない場合(parent)" do
      let(:family) { create(:family) }
      let!(:family_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(family_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "adminではない場合(teacher)" do
      let(:teacher) { create(:teacher) }
      let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let(:headers) { auth_headers_for(teacher_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def update_parents
  describe "PATCH api/v1/admin_parents_update" do
    let(:user_parent) { create(:user) }
    let(:family) { create(:family, user: user_parent) }
    let(:child) { create(:child, family: family) }
    let(:teacher) { create(:teacher) }
    let(:class_room) { create(:class_room, teacher: teacher) }

    before do
        child.class_rooms << class_room
      end

    subject { patch(api_v1_admin_parents_update_path(user_parent.id),  params: {
      name: "更新山田",
      children: [
        {
          id: child.id,
          name: "更新山田太郎",
          class_room_ids: [ class_room.id ]
        }
      ]
    },
    headers: headers
  )
}
    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "adminでログインしている場合" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }
      it "200が返り、更新する" do
        subject
        puts response.body
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res["message"]).to eq("更新しました")
      end
    end
    context "adminではない場合(parent)" do
      let(:family) { create(:family) }
      let!(:family_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(family_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "adminではない場合(teacher)" do
      let(:teacher) { create(:teacher) }
      let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let(:headers) { auth_headers_for(teacher_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def update_teacher
  describe "PATCH api/v1/admin_teachers_update" do
    let(:user_teacher) { create(:user, role: "teacher") }
    let(:teacher) { user_teacher.teacher }
    let(:class_room) { create(:class_room, teacher: teacher) }

    subject { patch(api_v1_admin_teachers_update_path(user_teacher.id), params: {
          name: "更新先生",
          class_room_id: class_room.id },
          headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "adminでログインしている場合" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }
      it "200が返り、更新する" do
        subject
        puts response.body
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res["message"]).to eq("更新しました")
      end
    end
    context "adminではない場合(parent)" do
      let(:family) { create(:family) }
      let!(:family_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(family_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "adminではない場合(teacher)" do
      let(:teacher) { create(:teacher) }
      let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let(:headers) { auth_headers_for(teacher_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def show_parent
  describe "GET api/v1/admin_parents_show" do
    let(:user_parent) { create(:user) }
    subject { get(api_v1_admin_parents_show_path(user_parent.id), headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "adminでログインしている場合" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }
      let(:family) { user_parent.family }
      let!(:child) { create(:child, family: user_parent.family) }
      let(:teacher) { create(:teacher) }
      let!(:class_room) { create(:class_room, teacher: teacher) }
      before do
        child.class_rooms << class_room
      end
      it "200が返り、更新する" do
        subject
        puts response.body
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res["children"].first).to eq({ "id" => child.id, "name" => child.name, "class_room_ids" => child.class_rooms.map { |c| c.id } })
      end
    end
    context "adminではない場合(parent)" do
      let(:family) { create(:family) }
      let!(:family_user) { create(:user, role: "parent", family: family) }
      let(:headers) { auth_headers_for(family_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "adminではない場合(teacher)" do
      let(:teacher) { create(:teacher) }
      let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let(:headers) { auth_headers_for(teacher_user) }
      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
