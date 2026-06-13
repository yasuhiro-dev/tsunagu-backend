class Api::V1::ClassRoomsController < ApplicationController
    def index
        class_rooms = ClassRoom.order(:grade, :section)
        render json: class_rooms, status: :ok
    end
end
