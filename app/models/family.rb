class Family < ApplicationRecord
    has_many :children
    has_many :family_unavailabilities
end
