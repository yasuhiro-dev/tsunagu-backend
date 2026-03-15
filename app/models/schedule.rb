class Schedule < ApplicationRecord
    has_many :children
    has_many :interview_slots
end
