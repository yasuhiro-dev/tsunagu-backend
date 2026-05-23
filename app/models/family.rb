class Family < ApplicationRecord
    has_many :children, dependent: :destroy
    has_many :family_unavailabilities, dependent: :destroy
    belongs_to :user
end
