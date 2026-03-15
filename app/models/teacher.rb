class Teacher < ApplicationRecord

   has_many :class_rooms
  has_many :meeting_slots

  enum :role, { regular: 0, special: 1 }
end
