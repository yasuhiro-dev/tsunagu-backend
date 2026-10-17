# デモ用の保護者（参加できる日時が、同じ1枠しかない2家庭）
# 自動割り当てでは片方しかその枠に入れず、もう片方は「未割り当て児童」として残る。
# 教師画面（STEP 4）で、未割り当て児童の手動割り当てを体験できるようにするためのデータ。
# このファイルだけを流しても重複しないようにしてある（bin/rails runner db/seeds/demo_unassigned_children.rb）
schedule = Schedule.find_by!(name: "2026年個別面談", year: 2026)
class_room = ClassRoom.find_by!(grade: 1, section: 1)
# 1年1組の担任の、最後の面談枠
only_slot = MeetingSlot.where(schedule: schedule, teacher: class_room.teacher).order(:start_at).last

[
  [ "parent-narrow1@example.com", "森本直子", "もりもとなおこ", "森本湊", "もりもとみなと" ],
  [ "parent-narrow2@example.com", "西田恵", "にしだめぐみ", "西田葵", "にしだあおい" ]
].each do |email, parent_name, parent_name_kana, child_name, child_name_kana|
  user = User.find_or_create_by!(email_address: email) do |u|
    u.password = "password"
    u.role = "parent"
    u.role_name = parent_name
    u.role_name_kana = parent_name_kana
  end
  family = user.family
  child = Child.find_or_create_by!(
    name: child_name, name_kana: child_name_kana,
    family: family, schedule: schedule
  )
  ChildClassRoom.find_or_create_by!(child: child, class_room: class_room)
  # 参加できる日時は1枠だけ選んで、提出済みにしておく
  family.family_availabilities.find_or_create_by!(meeting_slot: only_slot)
  family.update!(submitted: true)
end
