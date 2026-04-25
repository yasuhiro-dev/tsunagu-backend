class Api::V1::MeetingSlotsController < ApplicationController
    before_action :authenticate_user!
    def index
        family = current_user.family
        teacher_ids = family.children.flat_map { |child|child.class_rooms.map(&:teacher_id) }
        slots = MeetingSlot.where(teacher_id: teacher_ids)
        render json: slots
    end
end
