FactoryBot.define do
    factory :assignment_notification do
        association :child
        association :meeting_slot
        sent_at { Time.current }
    end
end
