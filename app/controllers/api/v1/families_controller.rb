class Api::V1::FamiliesController < ApplicationController
  before_action -> { authorize_role!("admin", "teacher", "parent") }
  def show
    family = Family.find(params[:id])
    render json: { submitted: family.submitted }, status: :ok
  end
end
