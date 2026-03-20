class TimeConstraints
  def time_ok?(family, slot)
    !FamilyUnavailability.exists?(
      family_id: family.id,
      meeting_slot_id: slot.id
    )
  end
end