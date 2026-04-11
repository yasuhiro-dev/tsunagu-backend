FactoryBot.define do
  factory :meeting_slot do
    association :teacher
    association :schedule
    start_at { Time.current }
    end_at { Time.current + 15.minutes }
    status { 0 }
  end
end
