# デモ環境を「seed直後（誰もデモを体験していない状態）」に戻す
class DemoResetter
  # デモ体験で操作する教師・保護者（フロントの DEMO_ACCOUNTS と同じアカウント）
  DEMO_TEACHER_EMAIL = "aoki@example.com"
  DEMO_PARENT_EMAIL = "parent-nonsubmit@example.com"
  # 最初の面談日が、今日からこの期間より近づいたら日程を先へ送る
  MIN_LEAD_TIME = 3.weeks
  # 日程を送るときは、最初の面談日が今日からこの期間より先になるようにする
  LEAD_TIME = 4.weeks
  # 締切日は最初の面談日の2週間前（seedと同じ）
  DEADLINE_BEFORE_FIRST_SLOT = 2.weeks

  def call
    # 途中で失敗して中途半端な状態が残らないよう、まとめて実行する
    ActiveRecord::Base.transaction do
      reset_assignments
      reset_teacher_slots
      reset_parent_submission
      reset_dates
    end
  end

  private

  # STEP3・STEP5：割り当てと通知の記録を消し、予約済みの枠を空きに戻す
  def reset_assignments
    AssignmentNotification.delete_all
    Assignment.delete_all
    MeetingSlot.reserved.update_all(status: :available)
  end

  # STEP1：デモ教師が「対応できない」にした枠を空きに戻す
  def reset_teacher_slots
    teacher = User.find_by(email_address: DEMO_TEACHER_EMAIL)&.teacher
    return unless teacher
    teacher.meeting_slots.blocked.update_all(status: :available)
  end

  # STEP2：デモ保護者を未提出に戻し、選んだ日時を消す
  def reset_parent_submission
    family = User.find_by(email_address: DEMO_PARENT_EMAIL)&.family
    return unless family
    family.family_availabilities.delete_all
    family.update!(submitted: false)
  end

  # 日数がたっても締切切れで操作できなくならないよう、面談日と締切日を今日基準に直す
  def reset_dates
    schedule = Schedule.current
    first_slot_date = schedule&.meeting_slots&.minimum(:start_at)&.to_date
    return unless first_slot_date

    if first_slot_date < Date.current + MIN_LEAD_TIME
      # 曜日が変わらないよう、週単位で先へ送る
      weeks = ((Date.current + LEAD_TIME - first_slot_date) / 7.0).ceil
      days = weeks * 7
      schedule.meeting_slots.update_all([
        "start_at = DATE_ADD(start_at, INTERVAL ? DAY), end_at = DATE_ADD(end_at, INTERVAL ? DAY)", days, days
      ])
      first_slot_date += days
    end
    schedule.update!(deadline_at: first_slot_date - DEADLINE_BEFORE_FIRST_SLOT)
  end
end
