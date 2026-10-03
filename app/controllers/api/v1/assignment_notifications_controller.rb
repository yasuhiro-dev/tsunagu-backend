class Api::V1::AssignmentNotificationsController < ApplicationController
before_action -> { authorize_role!("admin") }

before_action :set_notifier # 先にメソッドを定義



    def create # 通知メールを「送信する」ための操作用
        # 未送信ユーザーが０人の場合は何もしない(バリデーション)
        if @notifier.unnotified_assignment_count == 0
           render json: { status: "no_unnotified" }, status: :ok
           return
        end
        # デモの管理者が押したときは dry_run: trueと判定してジョブに渡す
        AssignmentNotificationJob.perform_later(dry_run: current_user.demo?) # true なら試運転、false なら本番
        render json: { status: "started" }, status: :ok
    end

    # 未連携教師・未送信ユーザーの情報を取得

    def index
        # 未送信ユーザーの数
        unnotified_count = @notifier.unnotified_assignment_count
        # 　送信済みユーザー数
        notified_count = @notifier.notified_count
        # 送信ユーザー＋未送信ユーザーの数
        all_user_count = @notifier.all_user_count
        # 未送信ユーザー情報（保護者・児童・クラス・担当教諭）を取得
        unnotified_details = @notifier.unnotified_details
        # 未連携教師の名前・クラス名
        unlinked_teachers = Teacher.joins(:user)
                                  .where(users: { google_access_token: nil })
                                  .includes(:class_rooms)
                                  .map do |teacher|
                                  { teacher_name: teacher.name, class_room: teacher.class_rooms.first&.classname }
                                  end
        render json: {
            notified_count: notified_count,
            unnotified_count: unnotified_count,
            unlinked_teachers: unlinked_teachers,
            all_user_count: all_user_count,
            unnotified_details: unnotified_details
        }, status: :ok
    end

    private

    def set_notifier # ２つのメソッド内で使用するためインスタンス変数にする
    @notifier = AssignmentNotifier.new
    end
end
