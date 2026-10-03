require "rails_helper"

RSpec.describe "Api::V1::AssignmentNotification", type: :request do
    describe "POST api/v1/assignment_notifications" do
        let(:admin) { create(:user, role: "admin") }
        let(:headers) { auth_headers_for(admin) }
        subject { post(api_v1_assignment_notifications_path, headers: headers) }

        context "未ログインの場合" do
            let(:headers) { {} }
            it_behaves_like "未ログインだと401が返る"
        end
        context "adminでない場合(teacher)" do
            let(:teacher) { create(:user, role: "teacher") }
            let(:headers) { auth_headers_for(teacher) }
            it "teacherだと401が返る" do
            subject
            expect(response).to have_http_status(:unauthorized)
            end
        end
        context "adminでない場合(parent)" do
            let(:parent) { create(:user, role: "parent") }
            let(:headers) { auth_headers_for(parent) }
            it "parentだと401が返る" do
            subject
            expect(response).to have_http_status(:unauthorized)
            end
        end
        context "adminでログインし、未通知ユーザーが0の場合" do
            it "メールの通知ができないようにする" do
                subject
            res = JSON.parse(response.body)
            expect(res).to eq({ "status" => "no_unnotified" })
            expect(response).to have_http_status(:ok)
            end
        end
        context "デモの admin の場合" do
            let!(:assignment) { create(:assignment) }
            it "メールの通知を開始しましたが返る" do
                subject
            res = JSON.parse(response.body)
            expect(res).to eq({ "status" => "started" })
            expect(response).to have_http_status(:ok)
            end
            let(:admin) { create(:user, role: "admin", email_address: "admin@example.com") }
            # ジョブへの依頼
            it "dry_run: trueを持ってジョブが予約される" do
            expect { subject }.to have_enqueued_job(AssignmentNotificationJob).with(dry_run: true)
            end
        end
        context "通常の admin の場合" do
            let!(:assignment) { create(:assignment) }
            let(:admin) { create(:user, role: "admin", email_address: "dry_run_false@example.com") }
            it "dry_run: falseを持ってジョブが予約される"  do
            expect { subject }.to have_enqueued_job(AssignmentNotificationJob).with(dry_run: false)
            end
        end
    end

    describe "GET api/v1/assignment_notifications" do
        let(:admin) { create(:user, role: "admin") }
        let(:headers) { auth_headers_for(admin) }
        subject { get(api_v1_assignment_notifications_path, headers: headers) }

        context "未ログインの場合" do
            let(:headers) { {} }
            it_behaves_like "未ログインだと401が返る"
        end
        context "管理者でない場合(教師)" do
            let(:teacher) { create(:user, role: "teacher") }
            let(:headers) { auth_headers_for(teacher) }
            it "teacherだと401が返る" do
            subject
            expect(response).to have_http_status(:unauthorized)
            end
        end
        context "管理者でない場合(保護者)" do
            let(:parent) { create(:user, role: "parent") }
            let(:headers) { auth_headers_for(parent) }
            it "parentだと401が返る" do
            subject
            expect(response).to have_http_status(:unauthorized)
            end
        end
        context "管理者の場合" do
            # ── ログイン用 ──
            let(:admin) { create(:user, role: "admin") }
            let(:headers) { auth_headers_for(admin) }
            # ── ① 通知済みの割り当て(notified_count 用) ──
            let!(:notified_assignment) { create(:assignment) } # 通知の割り当て＋通知に保存されてる記録
            let!(:assignment_notification) do # 通知の割り当て＋通知に保存されてる記録
                create(:assignment_notification,
                        child: notified_assignment.child,
                        meeting_slot: notified_assignment.meeting_slot)
            end
            # ── ② 未通知の割り当て(unnotified_details 用)。ここから保護者名・児童名・教師名・クラス名を取得する
            let!(:unnotified_assignment) { create(:assignment) } # 未通知の割り当て用（教師A作成される。保護者名・児童名も取得可）

            let!(:teacher_user) { create(:user, role: "teacher") } # teacher_nameを取り出すのにuserを経由する必要がある（serviceファイルに合わせた）
            let!(:slot_teacher_class_room) do # クラスに教師Aを入れる
                create(:class_room,
                        teacher: unnotified_assignment.meeting_slot.teacher)
            end
            before { unnotified_assignment.meeting_slot.teacher.update!(user: teacher_user, name: "面談担当先生") } # 教師A と Userをつなげる
            let(:slot_teacher_name)     { unnotified_assignment.meeting_slot.teacher.name } # 教師A の名前
            let(:slot_class_name)       { slot_teacher_class_room.classname } # クラス名
            # ── ③ 未連携教師(unlinked_teachers 用)。user はいるが Google 未連携(google_access_token: nil) ──
            let!(:unlinked_user) { create(:user, role: "teacher", google_access_token: nil) }
            let!(:unlinked_class_room) { create(:class_room) }
            let!(:unlinked_teacher_name) { unlinked_class_room.teacher.name } # 田中先生
            before { unlinked_class_room.teacher.update!(user: unlinked_user) }

            it "通知数・未通知数・未連携教師・全児童数・ユーザー情報を返す" do
            subject
            res = JSON.parse(response.body)
            expect(res["notified_count"]).to eq(1) # 通知数
            expect(res["unnotified_count"]).to eq(1) # 未通知数
            expect(res["unlinked_teachers"]).to include ({ "teacher_name" => unlinked_teacher_name, "class_room" =>unlinked_class_room.classname }) # 未連携教師
            expect(res["all_user_count"]).to eq(2) # 全児童数（未通知＋通知済みs）
            expect(res["unnotified_details"]).to eq([ {
                "parent_name" => unnotified_assignment.child.family.name,
                "child_name" => unnotified_assignment.child.name,
                "teacher_name" => slot_teacher_name,
                "class_name" => slot_class_name
            } ]) # 未通知の割り当ての詳細
            expect(response).to have_http_status(:ok)
            end
        end
    end
end
