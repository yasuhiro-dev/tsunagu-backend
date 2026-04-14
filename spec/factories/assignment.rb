FactoryBot.define do
    factory :assignment do
        association :child
        association :meeting_slot
    end
end
