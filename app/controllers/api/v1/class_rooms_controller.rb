class Api::V1::ClassRoomsController < ApplicationController
    skip_before_action :authenticate_user!, only: [ :index ]
    def index
        class_rooms = ClassRoom.order(:grade, :section)
        render json: class_rooms, status: :ok
    end
end
