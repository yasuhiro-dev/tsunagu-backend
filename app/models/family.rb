class Family < ApplicationRecord
    has_many :children, dependent: :destroy
    has_many :family_availabilities, dependent: :destroy
    belongs_to :user
    validates :name, presence: { message: "を入力してください" }

    # 保護者に見せる面談枠（担任の枠を、開始時刻で重複除去したもの）
    def selectable_slots
        teacher_ids = children.flat_map { |child| child.class_rooms.map(&:teacher_id) }
        MeetingSlot.where(teacher_id: teacher_ids).includes(assignments: :child)
                   .group_by(&:start_at).map { |_, slots| slots.first }
    end

    # 時間の制約（提出済みなら、参加できると答えた時刻以外は不可。未提出なら制約なし）
    def unavailable_start_at
        return [] unless submitted
        available_start_at = family_availabilities.map { |f|f.meeting_slot.start_at }
        selectable_slots.map(&:start_at) - available_start_at
    end
end
