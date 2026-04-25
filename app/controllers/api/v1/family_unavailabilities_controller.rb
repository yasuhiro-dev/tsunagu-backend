class Api::V1::FamilyUnavailabilitiesController < ApplicationController
    def create
        family = current_user.family
        unavailability = family.family_unavailabilities.create!(
            meeting_slot_id: params[:meeting_slot_id]
        )
        render json: unavailability, status: :created
    end
        def destroy
            family = current_user.family
            unavailabilities = family.family_unavailabilities.find_by!(
                meeting_slot_id: params[:meeting_slot_id]
            )
            unavailabilities.destroy!
            render json: { message: "delete" }, status: :ok
        end
end
