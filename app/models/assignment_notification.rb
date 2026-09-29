class AssignmentNotification < ApplicationRecord
  belongs_to :child
  belongs_to :meeting_slot
end
