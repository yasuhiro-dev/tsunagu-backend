class Api::V1::SchedulesController < ApplicationController
    before_action -> { authorize_role!("admin") }, only: [ :update ]
    before_action -> { authorize_role!("teacher") }, only: [ :create ]
    before_action -> { authorize_role!("teacher", "parent", "admin") }, only: [ :show ]

    # 教師が面談日程の割り当てを確定する
    def create
        teacher = current_user.teacher
        children = Child.joins(:child_class_rooms)
                        .where(child_class_rooms: { class_room_id: teacher.class_room_ids })
        schedule = Schedule.find(params[:id])
        teacher_meeting_slots=teacher.meeting_slots.where(schedule: schedule)
        teacher_meeting_slots.update_all(status: :available)
        Assignment.where(meeting_slot: teacher_meeting_slots).destroy_all
        Scheduling::ScheduleAssigner.new(schedule, children).call
        render json: { message: "success" }, status: :ok
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
