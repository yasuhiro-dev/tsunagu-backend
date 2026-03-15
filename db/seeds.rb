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



classes=[
    [1,1,"埜口","1年1組",:normal], [1,2,"高畠","1年2組",:normal],  [2,1,"黒羽","2年1組",:normal], 
    [2,2,"石井","2年2組",:normal],[3,1,"益子","3年1組",:normal],[3,2,"稲葉","3年2組",:normal], 
    [4,1,"大森","4年1組",:normal],[4,2,"武藤","4年2組",:normal],[5,1,"有坂","5年1組",:normal],
    [5,2,"米川","5年2組",:normal], [6,1,"小泉","6年1組",:normal],[6,2,"緑川","6年2組",:normal],
    [0,1,"園部","ひまわり",:support]
]
classes.each do |grade,section,teacher_name,class_name,room_type|
    teacher=Teacher.find_or_create_by!(name:teacher_name)

    ClassRoom.find_or_create_by!(
  grade: grade,
  section: section
) do |c|
  c.classname = class_name
  c.teacher = teacher
  c.room_type = room_type
end
end

family=["朝日","浅見","薄井","大友","大貫","川上","菊地","木谷","栗原","杉本","永井","三代","池田"]

family.each do |family_name|
    Family.find_or_create_by!(name:family_name)
end

child=[
    ["朝日晴信",1,5,1],["浅見祐奈",2,5,1],["薄井玲那",3,5,1],["大友朝日",4,5,1],
    ["大貫雄星",5,5,1],["川上結衣",6,5,1],["菊地英信",7,5,1],["木谷隼也",8,5,1],
    ["栗原寛太",9,5,1],["杉本響",10,5,1],["永井薫",11,5,2],["三代裕",12,0,1],
    ["薄井公平",3,6,2],["大友静子",4,6,1]
]

child.each do |child_name,family_id,grade,section|
    
    family= Family.find(family_id)

    class_room= ClassRoom.find_by!(
         grade:grade,
         section:section
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
  8.times do 
InterviewSlot.find_or_create_by!(
  schedule: schedule,
  status: :available,
  teacher:teacher,
  start_at:start_time,
  end_at:start_time+15.minutes
)

start_time += 15.minutes

end
end
end

Child.all.each do |child|
    slot = InterviewSlot.available.first
    break if slot.nil?
    Assignment.find_or_create_by!(
        child:child,
        interview_slot:slot
    )
    slot.update!(status: :reserved)
end

Family.all.each do |family|
InterviewSlot.all.sample(2).each do |slot|
    FamilyUnavailability.find_or_create_by!(
        family:family,
        interview_slot:slot
    )
    end
end


