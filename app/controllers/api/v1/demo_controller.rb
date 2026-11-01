class Api::V1::DemoController < ApplicationController
  before_action :require_demo_user

  # 「デモを体験する」を押したときに、デモ環境を初期状態へ戻す
  def reset
    DemoResetter.new.call
    render json: { message: "デモ環境を初期状態に戻しました" }, status: :ok
  end

  # 「担任でログイン」を押したときに、デモ環境を初期値に戻し、割り当てを開始する
  def prepare_guest
    ActiveRecord::Base.transaction do
    DemoResetter.new.call
    # デモ環境には schedule が1つしかない前提
    run_assignment!
    end
    render json: { message: "ゲスト用のデモ環境を準備しました" }, status: :ok
  rescue => e
    Rails.logger.error(e.full_message)
    render json: { error: "ゲスト用のデモ環境の準備に失敗しました" }, status: :unprocessable_entity
  end

  # 保護者が「日時の提出」を押したら割り当てがされる
  def assign
    ActiveRecord::Base.transaction { run_assignment! }
    render json: { message: "割り当てが実行されました" }, status: :ok
    rescue => e
      Rails.logger.error(e.full_message)
    render json: { error: "割り当てが失敗しました" }, status: :unprocessable_entity
  end

  # 教師が再提出した時に改めて割り当て直す
  def reassign
    # ログイン中のteacher
    teacher = current_user.teacher
    # フロントから送られてきた、対応できる枠の ID 一覧（空でも配列にし、数字にそろえる）
    available_ids = Array(params[:meeting_slot_ids]).map(&:to_i)

    ActiveRecord::Base.transaction do
       # いまの割り当て、割り当て通知を全部消す
       AssignmentNotification.delete_all
       Assignment.delete_all
       # 面談が入っていた枠（reserved）を available に戻す
       MeetingSlot.reserved.update_all(status: :available)
       # 担任が選んだ枠を available にする
       teacher.meeting_slots.where(id: available_ids).update_all(status: :available)
       # 担任が選ばなかった枠を blocked にする
       teacher.meeting_slots.where.not(id: available_ids).update_all(status: :blocked)
       # 割り当てをやり直す
       run_assignment!
    end
    render json: { message: "提出されました" }, status: :ok
    rescue => e
    Rails.logger.error(e.full_message)
    render json: { error: "提出できませんでした" }, status: :unprocessable_entity
  end

  private

  # デモ環境のスケジュール全体に割り当てを実行する
  # （デモ環境には schedule が1つしかない前提）
  def run_assignment!
    schedule = Schedule.current
    children = Child.where(schedule: schedule)
    Scheduling::ScheduleAssigner.new(schedule, children).call
  end


  # デモアカウント以外からは実行させない（デモアカウントはデモ環境のseedにしか存在しない）
  def require_demo_user
    return if current_user.demo?
    render json: { error: "デモアカウントのみ実行できます" }, status: :forbidden
  end
end
