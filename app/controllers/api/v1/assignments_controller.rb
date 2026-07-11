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
            render json: assignment, status: :created
          else
            render json: { errors: assignment.errors.full_messages }, status: :unprocessable_entity
          end
        end
    end
  end
end
