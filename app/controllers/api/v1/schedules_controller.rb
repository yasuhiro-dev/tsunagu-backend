class Api::V1::SchedulesController < ApplicationController
    def create
        schedule = Schedule.find(params[:id])
        schedule.meeting_slot.update_all(status: :available)
        Assignment.where(meeting_slot: schedule.meeting_slots).destroy_all
        Scheduling::ScheduleAssigner.new(schedule).call
        render json: { message: "success" }, status: :ok
    end
end
