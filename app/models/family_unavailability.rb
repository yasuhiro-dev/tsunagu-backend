class FamilyUnavailability < ApplicationRecord
  belongs_to :family
  belongs_to :meeting_slot
  validate :check_deadline

  private

  def check_deadline
    return if meeting_slot.schedule.deadline_at.nil?
    if meeting_slot.schedule.deadline_at  < Time.current
      errors.add(:base,"締め切りが過ぎているため、変更できません")
    end
  end
end
