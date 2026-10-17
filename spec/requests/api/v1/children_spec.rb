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
      # teacherを作る
      let!(:teacher) { create(:teacher) }
      # teacherが所属するclass_roomを作る
      let!(:class_room) { create(:class_room, teacher: teacher) }
      # 現在ログイン中のteacherを作り、headersへ
      let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let(:headers) { auth_headers_for(teacher_user) }
      # 児童に作成しクラスを当てはめる
      let!(:child) { create(:child) }
      before do
        child.class_rooms << class_room
      end


      it "200が返り、割り当てされていないchildの情報が渡る" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        puts "res:#{res}"
        # 配列のためfirstで１件だけ取得
        expect(res.first.keys).to include("id", "child_name", "family_name")
      end

      context "保護者が参加できる日時を提出している場合" do
        let(:later) { Time.zone.parse("2026-11-18 16:15") }
        let(:earlier) { Time.zone.parse("2026-11-17 15:00") }
        let!(:later_slot) { create(:meeting_slot, teacher: teacher, start_at: later, end_at: later + 15.minutes) }
        let!(:earlier_slot) { create(:meeting_slot, teacher: teacher, start_at: earlier, end_at: earlier + 15.minutes) }
        before do
          create(:family_availability, family: child.family, meeting_slot: later_slot)
          create(:family_availability, family: child.family, meeting_slot: earlier_slot)
          child.family.update!(submitted: true)
        end

        it "提出済みであることと、参加できる時刻が早い順に渡る" do
          subject
          res = JSON.parse(response.body)
          expect(res.first["submitted"]).to eq(true)
          expect(res.first["available_start_at"].map { |t| Time.zone.parse(t) }).to eq([ earlier, later ])
        end
      end

      context "保護者が未提出の場合" do
        it "未提出であることと、空の時刻が渡る" do
          subject
          res = JSON.parse(response.body)
          expect(res.first["submitted"]).to eq(false)
          expect(res.first["available_start_at"]).to eq([])
        end
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
      let!(:teacher) { create(:teacher) }
      let!(:teacher_user) { create(:user, role: "teacher", teacher: teacher) }
      let!(:headers) { auth_headers_for(teacher_user) }
      # teacherが所属するclass_roomを作る
      let(:class_room) { create(:class_room, teacher: teacher) }
      # 児童を作る
      let!(:child) { create(:child) }
      # 児童に作成したクラスを当てはめる
      before do
        child.class_rooms << class_room
      end

      it "200が返り、childの情報が渡る" do
        subject
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        # children は配列のため、first で1件だけ取得
        expect(res["children"].first.keys).to include("id", "child_name", "family_name")
      end
      it "担任クラスの名前が class_names に入る" do
        subject
        res = JSON.parse(response.body)
        expect(res["class_names"]).to eq([ class_room.classname ])
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
