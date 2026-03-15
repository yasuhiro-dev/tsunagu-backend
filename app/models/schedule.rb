class Schedule < ApplicationRecord
    has_many :children
    has_many :meeting_slots
end
