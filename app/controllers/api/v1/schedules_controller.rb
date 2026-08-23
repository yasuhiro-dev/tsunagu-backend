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
        # 確認メールを送信する
        assignments = Assignment.where(meeting_slot: meeting_slots)
                                .includes(meeting_slot: { teacher: [ :user, :class_rooms ] }, child: { family: :user }) # 今年の面談表だけに絞る
        assignments.each { |assignment| send_confirmation_email(assignment) }

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
    # 今年度のschedule_idをフロントへ返す
    def current
    schedule = Schedule.current
    render json: schedule
    end

    private
        # 面談決定メールのメソッド
        def send_confirmation_email(assignment)
          teacher_user = assignment.meeting_slot.teacher.user
          parent_user = assignment.child.family.user
          child_name = assignment.child.name
          teacher_name = teacher_user.teacher.name
          class_room = teacher_user.teacher.class_rooms.first
          class_name = class_room.classname
          GmailService.new(teacher_user).send_email(
            to: parent_user.email_address,
            subject: "面談日程のご案内",
            body: <<~BODY
             保護者様

            いつもお世話になっております。
            #{child_name}さんの面談が確定しました。

            【日時】#{assignment.meeting_slot.start_at.strftime('%-m月%-d日 %-H時%M分')}から#{assignment.meeting_slot.end_at.strftime('%-H時%M分')}
            【場所】#{class_name}
            【担任】#{teacher_name}

            【準備物】
            ・上履き
            ・ネームプレート

            日程の変更をご希望の場合は、
            学校までお電話にてご連絡ください。

            ---
            このメールは Tsunagu より自動送信されています。

            BODY
          )
            rescue => e
          Rails.logger.error("[gmail] assignment=#{assignment.id} teacher_user=#{teacher_user&.id} #{e.class}: #{e.message}")
        end
end
