class AssignmentNotifier
  def unnotified_assignment
    # 通知済みユーザー
    notified = AssignmentNotification.pluck(:child_id, :meeting_slot_id)
    # 全割り当てを集める
    Assignment.includes(
    meeting_slot: { teacher: [ :user, :class_rooms ] },
    child: { family: :user }
    ).select do |assignment| # その中から、未通知のものだけ残す
      assignment_pair = [ assignment.child_id, assignment.meeting_slot_id ]
      !notified.include?(assignment_pair)
    end
  end

  # 送信する
  def call(dry_run: false)
    unnotified_assignment.each do |assignment| # unnotified_assignmentメソッドを呼ぶ
      begin
        send_mail(assignment) unless dry_run # dry_runがfalse(本番)のときだけ送信する

        # 送らなくても通知済みにする(デモ用も通知済みになる)
        AssignmentNotification.create!(
          child_id: assignment.child_id,
          meeting_slot_id: assignment.meeting_slot_id,
          sent_at: Time.current
        )
      rescue OAuth2::Error, Faraday::Error # Gmail通信のエラー
        raise # call の呼び出し元(perform)へ飛ぶ
      rescue => e # Gmail通信とは関係のない、予期しない種類のエラー
        Rails.logger.error("通知送信エラー: assignment_id=#{assignment.id} #{e.message}")
        next
      end
    end
  end

  # 未通知ユーザーの表示/未通知ユーザーが0の場合のバリデーションで使用
  def unnotified_assignment_count
    unnotified_assignment.count
  end

  # 通知済みユーザーの表示に使用（割り当て全体　ー　未通知　＝　通知）
  def notified_count
   all_user_count - unnotified_assignment_count
  end

  # 全ユーザーの数(割り当てされている数)
  def all_user_count
    Assignment.count
  end

  # 未送信ユーザー情報(保護者・児童・クラス・担当教諭)を取得
  def unnotified_details
    unnotified_assignment.map do |assignment| # 未通知のユーザーのみ取得
      parent_name = assignment.child.family.name # 保護者名
      child_name = assignment.child.name # 児童名
      teacher_user = assignment.meeting_slot.teacher.user
      teacher_name = teacher_user.teacher.name # 教師名
      class_name = teacher_user.teacher.class_rooms.first&.classname # クラス名
      { parent_name: parent_name, child_name: child_name, teacher_name: teacher_name, class_name: class_name }
    end
  end

  private

  # 1件分の面談確定メールを、担任のGmailアカウントから送る
  def send_mail(assignment)
    teacher_user = assignment.meeting_slot.teacher.user
    teacher = teacher_user.teacher
    class_name = teacher.class_rooms.first&.classname
    parent_user = assignment.child.family.user
    parent_user_mail = parent_user.email_address

    GmailService.new(teacher_user).send_email(
      to: parent_user_mail,
      subject: "面談日程のご案内",
      body: <<~BODY
        保護者様

        いつもお世話になっております。
        #{assignment.child.name}さんの面談が確定しました。

        【日時】#{assignment.meeting_slot.start_at.strftime('%-m月%-d日 %-H時%-M分')}から#{assignment.meeting_slot.end_at.strftime('%-H時%-M分')}
        【場所】#{class_name}
        【担任】#{teacher.name}

        【準備物】
        ・上履き
        ・ネームプレート

        日程の変更をご希望の場合は、
        学校までお電話にてご連絡ください。

        ---
        このメールは Tsunagu(面談日程調整システム)より、担任のアカウントで送信されています。
      BODY
    )
  end
end
