module Api
  module V1
    class AssignmentsController < ApplicationController
      before_action -> { authorize_role!("admin", "teacher") }
        def create
          assignment = Assignment.new(
            meeting_slot_id: params[:meeting_slot_id],
            child_id: params[:child_id]
          )
          if assignment.save
            send_confirmation_email(assignment)
            render json: assignment, status: :created
          else
            render json: { errors: assignment.errors.full_messages }, status: :unprocessable_entity
          end
        end
        private
        def send_confirmation_email(assignment)
          teacher_user = assignment.meeting_slot.teacher.user
          parent_user = assignment.child.family.user
          GmailService.new(teacher_user).send_email(
            to: parent_user.email_address,
            subject: "面談が確定しました",
            body: "#{assignment.child.name}さんの面談は#{assignment.meeting_slot.start_at.strftime('%-m月%-d日 %-H時%-M分')}からです。")
            rescue => e
              Rails.logger.error("メール送信に失敗しました: #{e.message}")
            end
    end
  end
end
