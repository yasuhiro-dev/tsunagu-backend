class Teacher < ApplicationRecord

   has_many :class_rooms
  has_many :interview_slots

  enum :role, { regular: 0, special: 1 }
end
