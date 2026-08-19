class Api::V1::SchedulesController < ApplicationController
    before_action -> { authorize_role!("admin") }, only: [ :update, :create ]
    before_action -> { authorize_role!("teacher", "parent", "admin") }, only: [ :show ]


    # 管理者が面談日程の割り当てを確定する

    def create
        unassigned = []
        # 2026年度版
        schedule = Schedule.find(params[:id])
        # 2026年度のchildを取得
        children = Child.where(schedule: schedule)
        # 割り当てをリセットする
        meeting_slots = schedule.meeting_slots
        reserved_slots = meeting_slots.where(status: :reserved)
        # 割り当てが中途半端にならないようにエラーが起きたら中止
        ActiveRecord::Base.transaction do
        reserved_slots.update_all(status: :available) # 予約を全リセット
        Assignment.where(meeting_slot: meeting_slots).destroy_all # slotを全削除
        # サービスクラスに渡し、調整されて割り当てされる
        unassigned_children = Scheduling::ScheduleAssigner.new(schedule, children).call
        unassigned.concat(unassigned_children)
        end
        render json: { message: "success", unassigned_children: unassigned }, status: :ok
        rescue => e
            render json: { error: "割り当てに失敗しました: #{e.message}" }, status: :unprocessable_entity
    end

    # 締切日を参照する
    def show
        # フロントからid=1が送られた場合2026年のschedule
        schedule = Schedule.find(params[:id])
        deadline = schedule.deadline_at
        render json: { deadline_at: deadline }, status: :ok
    end

    # 管理者が締切日を設定する
    def update
        # フロントから設定した日付を取得する
        new_deadline = params[:deadline_at]
        schedule = Schedule.find(params[:id])
        schedule.update(deadline_at: new_deadline)
        # 更新されたDBから取り出す
        update_schedule = schedule.deadline_at
        # フロント側も情報を更新できるように返す
        render json: { deadline_at: update_schedule }, status: :ok
    end
end
