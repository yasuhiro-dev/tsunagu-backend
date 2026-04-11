FactoryBot.define do
  factory :class_room do
    association :teacher
    classname { "5年3組" }
    grade { 5 }
    section { 3 }
    room_type { 0 }
  end
end
