# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
schedule = Schedule.find_or_create_by!(
  name: "2026年個別面談",
  year: 2026)



classes = [
  [ 1, 1, "埜口", "1年1組", :normal ],
  [ 1, 2, "高畠", "1年2組", :normal ],
  [ 2, 1, "黒羽", "2年1組", :normal ],
  [ 2, 2, "石井", "2年2組", :normal ],
  [ 3, 1, "益子", "3年1組", :normal ],
  [ 3, 2, "稲葉", "3年2組", :normal ],
  [ 4, 1, "大森", "4年1組", :normal ],
  [ 4, 2, "武藤", "4年2組", :normal ],
  [ 5, 1, "有坂", "5年1組", :normal ],
  [ 5, 2, "米川", "5年2組", :normal ],
  [ 6, 1, "小泉", "6年1組", :normal ],
  [ 6, 2, "緑川", "6年2組", :normal ],
  [ 0, 1, "園部", "ひまわり", :support ]
]

classes.each do |grade, section, teacher_name, class_name, room_type|
  user = User.find_or_create_by!(email_address: "#{teacher_name}@example.com") do |u|
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

family_names = [ "朝日", "浅見", "薄井", "大友", "大貫", "川上", "菊地", "木谷", "栗原", "杉本", "永井", "三代", "池田" ]
family_names.each do |family_name|
  user = User.find_or_create_by!(email_address: "#{family_name}@example.com") do |u|
    u.password = "password"
    u.role = "parent"
  end
  user.family.update!(name: family_name)
end

child=[
    [ "朝日晴信", "朝日", 5, 1 ], [ "浅見祐奈", "浅見", 5, 1 ], [ "薄井玲那", "薄井", 5, 1 ], [ "大友朝日", "大友", 5, 1 ],
    [ "大貫雄星", "大貫", 5, 1 ], [ "川上結衣", "川上", 5, 1 ], [ "菊地英信", "菊地", 5, 1 ], [ "木谷隼也", "木谷", 5, 1 ],
    [ "栗原寛太", "栗原", 5, 1 ], [ "杉本響", "杉本", 5, 1 ], [ "永井薫", "永井", 5, 2 ], [ "三代裕", "三代", 0, 1 ],
    [ "薄井公平", "薄井", 6, 2 ], [ "大友静子", "大友", 6, 1 ]
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
