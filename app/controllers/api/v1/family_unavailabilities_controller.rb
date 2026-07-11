class Api::V1::FamilyUnavailabilitiesController < ApplicationController
    before_action -> { authorize_role!("parent") }

    def index
        family = current_user.family
        unavailabilities = family.family_unavailabilities.pluck(:meeting_slot_id)
        render json: unavailabilities, status: :ok
    end

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

  def update
    family = Family.find(params[:family_id])
    if family.submitted
        render json: { error: "すでに提出されています" }, status: :forbidden
    else
       family.update(submitted: true)
       render json: { message: "提出されました" }, status: :ok
    end
  end
end
