FactoryBot.define do
    factory :family_unavailability do
        association :family
        association :meeting_slot
    end
end
