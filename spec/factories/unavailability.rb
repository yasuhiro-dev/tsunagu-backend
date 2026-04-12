FactoryBot.define do
    factory :unavailability, class: FamilyUnavailability do
        association :family
        association :meeting_slot
    end
end
