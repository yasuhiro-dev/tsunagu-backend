class Api::V1::MeetingSlotsController < ApplicationController
    before_action :authenticate_user!
    def index
        teacher = current_user.teacher
        slots = teacher.meeting_slots.includes(assignments: { child: :family })
        render json: slots
    end
end
