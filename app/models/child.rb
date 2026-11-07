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
  # 　未割り当て児童と面談表（児童の教師・保護者・兄弟・特支の制約）を取得
  def valid_slots_data(exclude_assignment_id: nil)
          # 時間の制約（familyモデルでメソッド管理）
          unavailable_start_at = family.unavailable_start_at # 関連づけられるためにfamilyを取得してから

          # 兄弟関係の面談表(childモデルでメソッド管理)
          siblings_meeting_schedule = siblings.map { |sibling|sibling.related_schedules } # 面談表を取得している

          # 兄弟の時刻を取得する
          siblings_start_at = siblings.flat_map { |sibling|sibling.assignments.map { |a|a.meeting_slot&.start_at } }.compact

          # 特別支援の時刻を取得する
          own_assignments = assignments
          own_assignments = own_assignments.where.not(id: exclude_assignment_id) if exclude_assignment_id # 入れ替え時は、今選んでいる割り当てを含めない
          own_support_start_at = own_assignments.map { |a| a.meeting_slot&.start_at }.compact

          # 特別支援の面談表
          own_support_meeting_schedule = related_schedules
         { unavailable_start_at: unavailable_start_at,
           siblings_meeting_schedule: siblings_meeting_schedule,
           own_support_meeting_schedule: own_support_meeting_schedule,
           siblings_start_at: siblings_start_at,
           own_support_start_at: own_support_start_at }
  end
end
