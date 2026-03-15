class Assignment < ApplicationRecord
  belongs_to :child
  belongs_to :interview_slot
end
