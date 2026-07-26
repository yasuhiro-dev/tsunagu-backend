Faker::Config.locale = 'ja'

schedule = Schedule.find_or_create_by!(
  name: "2026年個別面談",
  year: 2026)

  

User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.password="password"
  u.role="admin"
end

classes = [
  [ 1, 1, "青木", "あおき", "aoki", "1年1組", :normal ],
  [ 1, 2, "石川", "いしかわ", "ishikawa", "1年2組", :normal ],
  [ 2, 1, "上田", "うえだ", "ueda", "2年1組", :normal ],
  [ 2, 2, "遠藤", "えんどう", "endo", "2年2組", :normal ],
  [ 3, 1, "岡田", "おかだ", "okada", "3年1組", :normal ],
  [ 3, 2, "加藤", "かとう", "kato_t", "3年2組", :normal ],
  [ 4, 1, "木村", "きむら", "kimura", "4年1組", :normal ],
  [ 4, 2, "小林", "こばやし", "kobayashi_t", "4年2組", :normal ],
  [ 5, 1, "斎藤", "さいとう", "saito", "5年1組", :normal ],
  [ 5, 2, "佐々木", "ささき", "sasaki", "5年2組", :normal ],
  [ 6, 1, "田中", "たなか", "tanaka_t", "6年1組", :normal ],
  [ 6, 2, "中村", "なかむら", "nakamura_t", "6年2組", :normal ],
  [ 0, 1, "林", "はやし", "hayashi", "ひまわり", :support ]
]

classes.each do |grade, section, teacher_name, teacher_name_kana,teacher_email_local, class_name, room_type|
  user = User.find_or_create_by!(email_address: "#{teacher_email_local}@example.com") do |u|
    u.password = "password"
    u.role = "teacher"
  end
  teacher = user.teacher
  teacher.update!(name: teacher_name,name_kana:teacher_name_kana)

  ClassRoom.find_or_create_by!(grade: grade, section: section) do |c|
    c.classname = class_name
    c.teacher = teacher
    c.room_type = room_type
  end
end

normal_classes = classes.select{|c|c[6] != :support}
classes.each do |grade, section, teacher_name,teacher_name_kana, teacher_email_local, class_name, room_type|
  target_count= room_type == :support ? 10 : 20
  current_count = 0
  while current_count < target_count
    gimei_last_name = Gimei.last
    gimei_first_name = Gimei.first
    # １人目の苗字名前
    family_last_name = gimei_last_name.kanji
    family_last_name_kana = gimei_last_name.hiragana
    role_name = family_last_name
    role_name_kana = family_last_name_kana
    # Userテーブルに家族の苗字の情報が入る
    parent_user = User.create!(
      email_address:Faker::Internet.unique.email,
      password: "password",
      role:"parent",
      role_name:role_name,
      role_name_kana:role_name_kana
      )
    
    family = parent_user.family 
    # １人目の苗字＋名前
    family_full_name = family_last_name + gimei_first_name.kanji
    family_full_name_kana = family_last_name_kana + gimei_first_name.hiragana
    # Childテーブルに名前と家族情報を入れる
    first_child = Child.find_or_create_by!(name: family_full_name, family: family,name_kana:family_full_name_kana)
    # クラス情報を入れる
      class_room = ClassRoom.find_by!(
        grade: grade,   
        section: section
        )
    # 子供とクラスの情報を繋げる
      ChildClassRoom.find_or_create_by!(
        child: first_child,
        class_room: class_room
        ) 
    current_count += 1
    # ３０％の確率で処理を行う
    if rand < 0.3
    # 兄弟の下の名前を生成する
      gimei_siblings_first_name = Gimei.first
    # 兄弟の苗字＋名前
      siblings_full_name = family_last_name + gimei_siblings_first_name.kanji
      siblings_full_name_kana = family_last_name_kana + gimei_siblings_first_name.hiragana
    # Childテーブルにfamily情報を繋げる
      sibling_child =Child.find_or_create_by!(name:siblings_full_name, family: family ,name_kana:siblings_full_name_kana)
      classes_sample = normal_classes.sample
      siblings_class_room = ClassRoom.find_by!(
        grade:classes_sample[0],
        section:classes_sample[1]
      )
      ChildClassRoom.find_or_create_by!(
        child: sibling_child,
        class_room: siblings_class_room
        )
    end
    # 特別支援の子供の場合、通常学級のクラスも割り当てる
    if room_type == :support
      sample_classes = normal_classes.sample
      support_class_room = ClassRoom.find_by!(
        grade: sample_classes[0],
        section: sample_classes[1]
      )
      ChildClassRoom.find_or_create_by!(
        child: first_child,
        class_room: support_class_room
        )
    end
  end
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
  child_room_type = child.child_class_rooms.find{|c|c.class_room.room_type == "normal"}
  child_teacher = child_room_type.class_room.teacher
  slot = MeetingSlot.where(teacher:child_teacher).available.first
    next if slot.nil?
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
