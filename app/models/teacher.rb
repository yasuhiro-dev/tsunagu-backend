class Teacher < ApplicationRecord
  has_many :class_rooms, dependent: :destroy
  has_many :meeting_slots, dependent: :destroy
  belongs_to :user, optional: true
  enum :role, { regular: 0, special: 1 }
end
