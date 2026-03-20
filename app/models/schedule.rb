class Schedule < ApplicationRecord
  has_many :children
  has_many :meeting_slots

  has_many :families, through: :children
  has_many :family_unavailabilities, through: :meeting_slots
end