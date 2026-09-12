class Api::V1::FamilyAvailabilitiesController < ApplicationController
    before_action -> { authorize_role!("parent") }

    def index
        family = current_user.family
        availabilities = family.family_availabilities.pluck(:meeting_slot_id)
        render json: availabilities, status: :ok
    end

    def create
        family = current_user.family
        availability = family.family_availabilities.create!(
            meeting_slot_id: params[:meeting_slot_id]
        )
        render json: availability, status: :created
    end
    def destroy
        family = current_user.family
        availability = family.family_availabilities.find_by!(
             meeting_slot_id: params[:meeting_slot_id]
        )
       availability.destroy!
       render json: { message: "delete" }, status: :ok
    end

  def update
    family = current_user.family
    if family.submitted
        render json: { error: "すでに提出されています" }, status: :forbidden
    elsif family.family_availabilities.none?
        # 参加できる日時が0件だと、どの枠にも割り当てられないため
        render json: { error: "参加できる日時を1つ以上選んでください" }, status: :unprocessable_entity
    else
       family.update(submitted: true)
       render json: { message: "提出されました" }, status: :ok
    end
  end
end
