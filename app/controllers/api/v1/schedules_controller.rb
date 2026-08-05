class Api::V1::SchedulesController < ApplicationController
    before_action -> { authorize_role!("teacher") }
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
end
