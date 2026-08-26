class AssignmentConfirmationMailJob < ApplicationJob
  queue_as :default

  # Gmail API 側の一時的な失敗（レート制限・ネットワーク断）だけ再試行する。
  # Google未連携の RuntimeError はここに含めず、即 failed_executions に落として可視化する。
  retry_on OAuth2::Error, Faraday::Error, wait: :polynomially_longer, attempts: 3

  def perform(assignment_id)
    assignment = Assignment.includes(
      meeting_slot: { teacher: [ :user, :class_rooms ] },
      child: { family: :user }
    ).find_by(id: assignment_id)
    # 割り当てがやり直された等で対象が消えていたら、このジョブは無意味なので何もしない
    return if assignment.nil?

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
        このメールは Tsunagu より自動送信されています。
      BODY
    )
  end
end
