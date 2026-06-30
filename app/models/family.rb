class Family < ApplicationRecord
    has_many :children, dependent: :destroy
    has_many :family_unavailabilities, dependent: :destroy
    belongs_to :user
    validates :name, presence: { message: "を入力してください" }
end
