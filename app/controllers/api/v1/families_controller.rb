class Api::V1::FamiliesController < ApplicationController
  before_action :authenticate_user!

  def show
    family = Family.find(params[:id])
    render json: { submitted: family.submitted }, status: :ok
  end
end
