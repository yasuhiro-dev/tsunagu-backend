Faker::Config.locale = 'ja'

schedule = Schedule.find_or_create_by!(
  name: "2026年個別面談",
  year: 2026)

User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.password="password"
  u.role="admin"
end

classes = [
  [ 1, 1, "青木花子", "あおきはなこ", "aoki", "1年1組", :normal ],
  [ 1, 2, "石川健太", "いしかわけんた", "ishikawa", "1年2組", :normal ],
  [ 2, 1, "上田美咲", "うえだみさき", "ueda", "2年1組", :normal ],
  [ 2, 2, "遠藤大輔", "えんどうだいすけ", "endo", "2年2組", :normal ],
  [ 3, 1, "岡田真由美", "おかだまゆみ", "okada", "3年1組", :normal ],
  [ 3, 2, "加藤修", "かとうおさむ", "kato_t", "3年2組", :normal ],
  [ 4, 1, "木村由紀", "きむらゆき", "kimura", "4年1組", :normal ],
  [ 4, 2, "小林隆", "こばやしたかし", "kobayashi_t", "4年2組", :normal ],
  [ 5, 1, "斎藤香織", "さいとうかおり", "saito", "5年1組", :normal ],
  [ 5, 2, "佐々木誠", "ささきまこと", "sasaki", "5年2組", :normal ],
  [ 6, 1, "田中裕子", "たなかゆうこ", "tanaka_t", "6年1組", :normal ],
  [ 6, 2, "中村健一", "なかむらけんいち", "nakamura_t", "6年2組", :normal ],
  [ 0, 1, "林麻衣", "はやしまい", "hayashi", "ひまわり", :support ]
]

classes.each do |grade, section, teacher_name, teacher_name_kana, teacher_email_local, class_name, room_type|
  user = User.find_or_create_by!(email_address: "#{teacher_email_local}@example.com") do |u|
    u.password = "password"
    u.role = "teacher"
  end
  teacher = user.teacher
  teacher.update!(name: teacher_name, name_kana: teacher_name_kana)
  ClassRoom.find_or_create_by!(grade: grade, section: section) do |c|
    c.classname = class_name
    c.teacher = teacher
    c.room_type = room_type
  end
end

# デモ用の保護者（兄弟あり＋支援学級あり）
demo_user = User.find_or_create_by!(email_address: "parent@example.com") do |u|
  u.password = "password"
  u.role = "parent"
  u.role_name = "山田太郎"
  u.role_name_kana = "やまだたろう"
end
demo_family = demo_user.family

# 兄: 5年1組（通常学級のみ）
demo_older = Child.find_or_create_by!(
  name: "山田陽向", name_kana: "やまだひなた",
  family: demo_family, schedule: schedule
)
ChildClassRoom.find_or_create_by!(
  child: demo_older,
  class_room: ClassRoom.find_by!(grade: 5, section: 1)
)

# 弟: 1年1組（通常学級）＋ ひまわり（支援学級）
demo_younger = Child.find_or_create_by!(
  name: "山田結衣", name_kana: "やまだゆい",
  family: demo_family, schedule: schedule
)
[
  ClassRoom.find_by!(grade: 1, section: 1),   # 通常学級
  ClassRoom.find_by!(grade: 0, section: 1)    # ひまわり（支援学級）
].each do |room|
  ChildClassRoom.find_or_create_by!(child: demo_younger, class_room: room)
end

# 提出前の状態にしておく
demo_family.update!(submitted: false)

teachers = Teacher.all
# 面談の日程、枠の設定
start_date = Date.current + 1.month
dates = 5.times.map do |i|
  start_date + i
end
# 面談の時間設定
teachers.each do |teacher|
  dates.each do |date|
    start_time = Time.zone.parse("#{date} 15:00")
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

normal_classes = classes.select { |c|c[6] != :support }
classes.each do |grade, section, teacher_name, teacher_name_kana, teacher_email_local, class_name, room_type|
  target_count= room_type == :support ? 10 : 20
  current_count = 0
  while current_count < target_count
    gimei_last_name = Gimei.last
    gimei_first_name = Gimei.first

    # １人目の苗字名前
    family_last_name = gimei_last_name.kanji
    family_last_name_kana = gimei_last_name.hiragana

    gimei_parent_first_name = Gimei.first
    # 保護者名（苗字＋名前）
    parent_full_name = family_last_name + gimei_parent_first_name.kanji
    parent_full_name_kana = family_last_name_kana + gimei_parent_first_name.hiragana
    role_name = parent_full_name
    role_name_kana = parent_full_name_kana

    # Userテーブルに家族の苗字の情報が入る
    parent_user = User.find_or_create_by!(email_address: Faker::Internet.unique.email) do |u|
      u.password = "password"
      u.role = "parent"
      u.role_name = role_name
      u.role_name_kana = role_name_kana
    end

    family = parent_user.family
    # １人目の苗字＋名前
    family_full_name = family_last_name + gimei_first_name.kanji
    family_full_name_kana = family_last_name_kana + gimei_first_name.hiragana
    # Childテーブルに名前と家族情報を入れる
    first_child = Child.find_or_create_by!(name: family_full_name, family: family, name_kana: family_full_name_kana, schedule: schedule)
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
    # 15％の確率で処理を行う
    if rand < 0.15
      # 兄弟の下の名前を生成する
      gimei_siblings_first_name = Gimei.first
      # 兄弟の苗字＋名前
      siblings_full_name = family_last_name + gimei_siblings_first_name.kanji
      siblings_full_name_kana = family_last_name_kana + gimei_siblings_first_name.hiragana
      # Childテーブルにfamily情報を繋げる
      sibling_child =Child.find_or_create_by!(name: siblings_full_name, family: family, name_kana: siblings_full_name_kana, schedule: schedule)
      classes_sample = normal_classes.sample
      siblings_class_room = ClassRoom.find_by!(
        grade: classes_sample[0],
        section: classes_sample[1]
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
    unavailable_slots = MeetingSlot.where(teacher_id: class_room.teacher.id).sample(3)

    unavailability = unavailable_slots.each do |slot|
      family.family_unavailabilities.create!(meeting_slot_id: slot.id)
    end
    family.update(submitted: rand < 0.8)
  end

  # 締切（seed実行時から半年後。時間が経っても期限切れにならないように）
schedule.update!(deadline_at: 6.months.from_now)

# 割り当てを実行しておく（二重実行を防ぐため、まだ無いときだけ）
if Assignment.none?
  Scheduling::ScheduleAssigner.new(schedule, Child.where(schedule: schedule)).call
end
end
