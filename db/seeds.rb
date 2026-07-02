schedule = Schedule.find_or_create_by!(
  name: "2026年個別面談",
  year: 2026)

User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.password="password"
  u.role="admin"
end

classes = [
  [ 1, 1, "青木", "aoki", "1年1組", :normal ],
  [ 1, 2, "石川", "ishikawa", "1年2組", :normal ],
  [ 2, 1, "上田", "ueda", "2年1組", :normal ],
  [ 2, 2, "遠藤", "endo", "2年2組", :normal ],
  [ 3, 1, "岡田", "okada", "3年1組", :normal ],
  [ 3, 2, "加藤", "kato_t", "3年2組", :normal ],
  [ 4, 1, "木村", "kimura", "4年1組", :normal ],
  [ 4, 2, "小林", "kobayashi_t", "4年2組", :normal ],
  [ 5, 1, "斎藤", "saito", "5年1組", :normal ],
  [ 5, 2, "佐々木", "sasaki", "5年2組", :normal ],
  [ 6, 1, "田中", "tanaka_t", "6年1組", :normal ],
  [ 6, 2, "中村", "nakamura_t", "6年2組", :normal ],
  [ 0, 1, "林", "hayashi", "ひまわり", :support ]
]

classes.each do |grade, section, teacher_name, teacher_email_local, class_name, room_type|
  user = User.find_or_create_by!(email_address: "#{teacher_email_local}@example.com") do |u|
    u.password = "password"
    u.role = "teacher"
  end
  teacher = user.teacher
  teacher.update!(name: teacher_name)

  ClassRoom.find_or_create_by!(grade: grade, section: section) do |c|
    c.classname = class_name
    c.teacher = teacher
    c.room_type = room_type
  end
end

families = [
  { name: "山田健一", email: "yamada@example.com" },
  { name: "田中誠", email: "tanaka@example.com" },
  { name: "鈴木博", email: "suzuki@example.com" },
  { name: "佐藤陽子", email: "sato@example.com" },
  { name: "高橋恵子", email: "takahashi@example.com" },
  { name: "伊藤真一", email: "ito@example.com" },
  { name: "渡辺久美", email: "watanabe@example.com" },
  { name: "中村和夫", email: "nakamura@example.com" },
  { name: "小林洋子", email: "kobayashi@example.com" },
  { name: "加藤浩二", email: "kato@example.com" },
  { name: "吉田明美", email: "yoshida@example.com" },
  { name: "山口剛", email: "yamaguchi@example.com" },
  { name: "松本幸子", email: "matsumoto@example.com" }
]

families.each do |f|
  user = User.find_or_create_by!(email_address: f[:email]) do |u|
    u.password = "password"
    u.role = "parent"
    u.role_name = f[:name]
  end
end

child=[
    [ "山田太郎", "山田健一", 5, 1 ], [ "田中花子", "田中誠", 5, 1 ], [ "鈴木一郎", "鈴木博", 5, 1 ], [ "佐藤美咲", "佐藤陽子", 5, 1 ],
    [ "高橋健太", "高橋恵子", 5, 1 ], [ "伊藤さくら", "伊藤真一", 5, 1 ], [ "渡辺拓也", "渡辺久美", 5, 1 ], [ "中村彩", "中村和夫", 5, 1 ],
    [ "小林大輝", "小林洋子", 5, 1 ], [ "加藤愛", "加藤浩二", 5, 1 ], [ "吉田翔", "吉田明美", 5, 2 ], [ "山口葵", "山口剛", 0, 1 ],
    [ "松本蓮", "松本幸子", 6, 2 ], [ "鈴木陽子", "鈴木博", 6, 1 ]
]

child.each do |child_name, family_name, grade, section|
    family = Family.find_by!(name: family_name)

    class_room= ClassRoom.find_by!(
         grade: grade,
         section: section
    )

  child = Child.find_or_create_by!(name: child_name) do |c|
    c.family = family
    c.schedule = schedule
  end

  ChildClassRoom.find_or_create_by!(
    child: child,
    class_room: class_room
  )
end

child_miro = Child.find_by!(name: "山口葵")
normal_class = ClassRoom.find_by!(grade: 5, section: 1)
ChildClassRoom.find_or_create_by!(
  child: child_miro,
  class_room: normal_class
)

teachers = Teacher.all
start_date = Date.parse("2026-06-01")
dates = 5.times.map do |i|
  start_date + i
end

teachers.each do |teacher|
  dates.each do |date|
    start_time = Time.parse("#{date} 15:00")
    6.times do
      MeetingSlot.find_or_create_by!(
        schedule: schedule,
        teacher: teacher,
        start_at: start_time,
        end_at: start_time + 15.minutes
      ) do |slot|
        slot.status = :available
      end
      start_time += 15.minutes
    end
  end
end

Child.all.each do |child|
    slot = MeetingSlot.available.first
    break if slot.nil?
    Assignment.find_or_create_by!(
        child: child,
        meeting_slot: slot
    )
    slot.update!(status: :reserved)
end

Family.all.each do |family|
  MeetingSlot.all.sample(2).uniq.each do |slot|
    FamilyUnavailability.find_or_create_by!(
      family: family,
      meeting_slot: slot
    )
  end
end
