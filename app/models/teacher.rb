class Teacher < ApplicationRecord
  has_many :class_rooms
  has_many :meeting_slots
  belongs_to :user, optional: true
  enum :role, { regular: 0, special: 1 }
end
