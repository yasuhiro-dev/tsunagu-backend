class FamilyUnavailability < ApplicationRecord
  belongs_to :family
  belongs_to :interview_slot
end
