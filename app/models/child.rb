class Child < ApplicationRecord
  belongs_to :family
  has_many :assignments, dependent: :destroy
 belongs_to :schedule, optional: true
  has_many :child_class_rooms, dependent: :destroy
  has_many :class_rooms, through: :child_class_rooms
  validates :name, presence: { message: "を入力してください" }
end
