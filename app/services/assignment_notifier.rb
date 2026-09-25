# 保護者へ面談確定メールを送る
#
# 送信済みかどうかは assignment_notifications テーブルで管理する。
# 一括割り当てをやり直しても、同じ児童が同じ枠に入っていれば再送しない。
# 面談表でコマを移動した児童は meeting_slot_id が変わるため、自動的に再送の対象になる。
class AssignmentNotifier
  Result = Struct.new(:sent_count, :failed_count, keyword_init: true)

  def initialize(schedule)
    @schedule = schedule
  end

  def call
    sent_count = 0
    failed_count = 0

    unnotified_assignments.each do |assignment|
      # 1人分の失敗で全体を止めない。
      # 担任がGoogle未連携の場合、そのクラスだけ落ちて他のクラスには届く。
      # 失敗した児童は未通知のまま残るので、もう一度ボタンを押せば再送される。
      begin
        send_mail(assignment)
        AssignmentNotification.create!(
          child_id: assignment.child_id,
          meeting_slot_id: assignment.meeting_slot_id,
          sent_at: Time.current
        )
        sent_count += 1
      rescue => e
        Rails.logger.error("面談確定メールの送信に失敗しました (assignment_id: #{assignment.id}): #{e.message}")
        failed_count += 1
      end
    end

    Result.new(sent_count: sent_count, failed_count: failed_count)
  end

  # まだ通知していない割り当て
  def unnotified_assignments
    # 学校規模（数百件）なのでRuby側で突き合わせる
    notified = AssignmentNotification.pluck(:child_id, :meeting_slot_id).to_set

    assignments.reject { |assignment|
      notified.include?([ assignment.child_id, assignment.meeting_slot_id ])
    }
  end

  private

  def assignments
    Assignment.where(meeting_slot: @schedule.meeting_slots)
              .includes(
                meeting_slot: { teacher: [ :user, :class_rooms ] },
                child: { family: :user }
              )
  end

  def send_mail(assignment)
    teacher_user = assignment.meeting_slot.teacher.user
    parent_user  = assignment.child.family.user
    teacher      = teacher_user.teacher
    class_name   = teacher.class_rooms.first&.classname

    GmailService.new(teacher_user).send_email(
      to: parent_user.email_address,
      subject: "面談日程のご案内",
      body: <<~BODY
        保護者様

        いつもお世話になっております。
        #{assignment.child.name}さんの面談が確定しました。

        【日時】#{assignment.meeting_slot.start_at.strftime('%-m月%-d日 %-H時%M分')}から#{assignment.meeting_slot.end_at.strftime('%-H時%M分')}
        【場所】#{class_name}
        【担任】#{teacher.name}

        【準備物】
        ・上履き
        ・ネームプレート

        日程の変更をご希望の場合は、
        学校までお電話にてご連絡ください。

        ---
        このメールは Tsunagu（面談日程調整システム）より、担任のアカウントで送信されています。
      BODY
    )
  end
end
