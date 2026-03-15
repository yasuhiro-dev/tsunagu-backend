class FamilyUnavailability < ApplicationRecord
  belongs_to :family
  belongs_to :meeting_slot
end
