FactoryBot.define do
    factory :family_availability do
        association :family
        association :meeting_slot
    end
end
