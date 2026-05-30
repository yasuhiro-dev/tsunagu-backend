class ClassRoom < ApplicationRecord
    belongs_to :teacher
    has_many :child_class_rooms, dependent: :destroy
    has_many :children, through: :child_class_rooms
    enum :room_type, { normal: 0, support: 1 }
end
