module Api
  module V1
    class AssignmentsController < ApplicationController
      # 校内の教員は全員が面談調整に関わるため、担任クラスに関係なく参照可能とする
      before_action -> { authorize_role!("teacher") }

        def create
          # 既に割り当てられたslotと児童をDBに保存する
          assignment = Assignment.new(
            meeting_slot_id: params[:meeting_slot_id],
            child_id: params[:child_id]
          )
          # もし割り当てられたら、面談決定メールを送る
          if assignment.save
            send_confirmation_email(assignment)
            render json: assignment, status: :created
          else
            render json: { errors: assignment.errors.full_messages }, status: :unprocessable_entity
          end
        end

        # バリデーション表示（時間の制約・兄弟/特別支援面談表の取得）
        def valid_slots
          # フロントからURLに載せて１つのassignment_idを取得
          assignment = Assignment.find(params[:id])
          child = assignment.child

          # 時間の制約（familyモデルでメソッド管理）
          family = child.family
          unavailable_start_at = family.family_unavailability_start_at # 関連づけられるためにfamilyを取得してから

          # 兄弟関係の面談表(childモデルでメソッド管理)
          siblings = child.siblings
          siblings_meeting_schedule = siblings.map { |sibling|sibling.related_schedules }

          # 特別支援の面談表
          own_support_meeting_schedule = child.related_schedules
          render json: { unavailable_start_at: unavailable_start_at, siblings_meeting_schedule: siblings_meeting_schedule, own_support_meeting_schedule: own_support_meeting_schedule }, status: :ok
        end

        # 面談編集メソッド
        def reassign
           ActiveRecord::Base.transaction do
            # assignments=[{from_assignment_id（移動元）,to_slot_id（移動先）},{}...]
            params[:assignments].each do |item|
            # 移動元の情報をDBから取得
            from_assignment = Assignment.find(item[:from_assignment_id])
            # 移動元の場所を、覚えておく（移動してしまうと、交換場所がわからなくなるため）
            from_slot_id = from_assignment.meeting_slot_id
            to_slot_id = item[:to_slot_id]
            # 移動先に誰かいるかDBをチェック
            to_assignment = Assignment.find_by(meeting_slot_id: to_slot_id)

        # もしいたら、移動先の児童を、移動元の児童の場所（from_slot_id）へ/いなければnill
        if to_assignment
            Assignment.where(id: to_assignment.id)
            .update_all(meeting_slot_id: from_slot_id)
        end
        # 移動元の児童を、移動先の場所（to_slot_id）へ
        Assignment.where(id: from_assignment.id)
                  .update_all(meeting_slot_id: to_slot_id)
         end
        end
        # フロントの受け取りの型がMeetingSlotなのでその型に合わせてrenderする
        slots = MeetingSlot.where(teacher: current_user.teacher).includes(assignments: :child)
        render json: slots.map { |slot|
          {
            id: slot.id,
            start_at: slot.start_at,
            end_at: slot.end_at,
            status: slot.status,
            child_name: slot.assignments.first&.child&.name,
            assignment_id: slot.assignments.first&.id
          }
        }
      rescue => e
        render json: { error: "割り当ての修正に失敗しました: #{e.message}" }, status: :unprocessable_entity
      end

        private
        # 面談決定メールのメソッド
        def send_confirmation_email(assignment)
          teacher_user = assignment.meeting_slot.teacher.user
          parent_user = assignment.child.family.user
          GmailService.new(teacher_user).send_email(
            to: parent_user.email_address,
            subject: "面談が確定しました",
            body: "#{assignment.child.name}さんの面談は#{assignment.meeting_slot.start_at.strftime('%-m月%-d日 %-H時%-M分')}からです。")
            rescue => e
               p "エラー詳細: #{e.message}"
          Rails.logger.error("メール送信に失敗しました: #{e.message}")
        end
    end
  end
end
