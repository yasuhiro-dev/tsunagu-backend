class Child < ApplicationRecord
  belongs_to :family
  has_many :assignments
 belongs_to :schedule, optional: true
  has_many :child_class_rooms
  has_many :class_rooms, through: :child_class_rooms
end
