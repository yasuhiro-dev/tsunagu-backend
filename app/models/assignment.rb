class Assignment < ApplicationRecord
  belongs_to :child
  belongs_to :meeting_slot
  after_destroy :update_slot_status

  validates :child_id, uniqueness: { scope: :meeting_slot_id }

  private
      def update_slot_status
        meeting_slot = MeetingSlot.find(meeting_slot_id)
        meeting_slot.update(status: :available)
      end
end
