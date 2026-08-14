class Family < ApplicationRecord
    has_many :children, dependent: :destroy
    has_many :family_unavailabilities, dependent: :destroy
    belongs_to :user
    validates :name, presence: { message: "を入力してください" }

     # 時間の制約
    def family_unavailability_start_at
        family_unavailabilities.map{|f|f.meeting_slot.start_at}
    end
end
