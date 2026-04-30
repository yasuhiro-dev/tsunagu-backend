class Api::V1::SchedulesController < ApplicationController
    def create
        schedule = Schedule.find(params[:id])
        Scheduling::ScheduleAssigner.new(schedule).call
        render json: { message: "success" }, status: :ok
    end
end
