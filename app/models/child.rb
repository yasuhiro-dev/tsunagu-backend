class Child < ApplicationRecord
  belongs_to :family
  has_many :assignments, dependent: :destroy
 belongs_to :schedule, optional: true
  has_many :child_class_rooms, dependent: :destroy
  has_many :class_rooms, through: :child_class_rooms
  validates :name, presence: { message: "を入力してください" }

  # 兄弟を取得（自分は含まない）
  def siblings
    family.children.where.not(id: id)
  end
  # その児童のクラスから、面談表・クラス名・担任名・児童名を取得
  def related_schedules
    class_rooms.map do |class_room|
    teacher = class_room.teacher
    {
      teacher_name: teacher.name,
      class_room_name: class_room.classname,
      # slotsは複数なので1つのslotに絞ってから（N+1対策でassignmentとchildをincludes）
      slots: MeetingSlot.where(teacher: teacher).includes(assignments: :child).map { |slot| {
        # オブジェクトはmapを使うと再設定
        id: slot.id,
        start_at: slot.start_at,
        end_at: slot.end_at,
        status: slot.status,
        # assignmentsでアソシエーションが複数なので.firstにしてから取り出す
        child_name: slot.assignments.first&.child&.name
        }
      } }
  end
  end
end
