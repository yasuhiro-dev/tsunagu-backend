class Api::V1::GoogleCalendarController < ApplicationController
    before_action :authenticate_user!

    def create
        assignment = Assignment.find(params[:id])
        unless current_user.family.id == (assignment.child.family.id)
            return render json: { error: "権限がありません" }, status: :forbidden
        end

        GoogleCalendarService.new(current_user).register_calendar(
            summary: "面談日",
            start_at: assignment.meeting_slot.start_at,
            end_at: assignment.meeting_slot.end_at
          )
        render json: { message: "登録されました" }, status: :ok
          rescue => e
  render json: { error: "登録に失敗しました" }, status: :internal_server_error
    end
end
