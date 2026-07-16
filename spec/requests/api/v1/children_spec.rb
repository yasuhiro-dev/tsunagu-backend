require "rails_helper"

RSpec.describe "Api::V1::Children", type: :request do
  # def　unassignedアクション
  describe "GET api_v1_children_unassigned_path" do
    subject { get(api_v1_children_unassigned_path, headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "teacherでログインしている場合" do
      # 現在ログイン中のteacherを作り、headersへ
      let(:teacher_user) { create(:user, role: "teacher") }
      let(:headers) { auth_headers_for(teacher_user) }
      let!(:child) { create(:child) }

      it "200が返り、割り当てされていないchildの情報が渡る" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        # 配列のためfirstで１件だけ取得
        expect(res.first.keys).to include("id", "child_name", "family_name")
      end
    end

    context "teacherではない場合(parent)" do
      let(:parent_user) { create(:user, role: "parent") }
      let(:headers) { auth_headers_for(parent_user) }

      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "teacherではない場合(admin)" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }

      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # def indexアクション
  describe "GET api_v1_child_list_path" do
    subject { get(api_v1_child_list_path, headers: headers) }

    context "未ログインの場合" do
      let(:headers) { {} }
      it_behaves_like "未ログインだと401が返る"
    end

    context "teacherでログインしている場合" do
      # 現在ログイン中のteacherを作り、headersへ
      let(:teacher) { create(:teacher) }
      let(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let(:headers) { auth_headers_for(teacher_user) }
      # teacherが所属するclass_roomを作る
      let(:class_room) { create(:class_room, teacher: teacher) }
      # 児童を作る
      let(:child) { create(:child) }
      # 児童に作成したクラスを当てはめる
      before do
        child.class_rooms << class_room
      end

      it "200が返り、childの情報が渡る" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        # 配列のためfirstで１件だけ取得
        expect(res.first.keys).to include("id", "child_name", "family_name")
      end
    end

    context "teacherではない場合(parent)" do
      let(:parent_user) { create(:user, role: "parent") }
      let(:headers) { auth_headers_for(parent_user) }

      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "teacherではない場合(admin)" do
      let(:admin_user) { create(:user, role: "admin") }
      let(:headers) { auth_headers_for(admin_user) }

      it "401が返る" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
