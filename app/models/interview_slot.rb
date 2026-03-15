class InterviewSlot < ApplicationRecord
  belongs_to :teacher
  belongs_to :schedule
  has_many :assignments
  has_many :family_unavailabilities

  enum :status, { available: 0, reserved: 1, blocked: 2 }
end
