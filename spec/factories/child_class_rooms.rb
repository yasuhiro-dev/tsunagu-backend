FactoryBot.define do
    factory :child_class_room do
        association :child
        association :class_room
    end
end
