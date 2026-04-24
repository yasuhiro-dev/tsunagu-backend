class Api::V1::FamilyUnavailabilitiesController < ApplicationController
    def create
        family = current_user.family
        unavailability = family.family_unavailabilities.create!(
            meeting_slot_id: params[:meeting_slot_id]
        )
        render json: unavailability, status: :created
    end
end
