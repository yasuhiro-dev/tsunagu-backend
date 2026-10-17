class Api::V1::DemoController < ApplicationController
  before_action :require_demo_user

  # 「デモを体験する」を押したときに、デモ環境を初期状態へ戻す
  def reset
    DemoResetter.new.call
    render json: { message: "デモ環境を初期状態に戻しました" }, status: :ok
  end

  private

  # デモアカウント以外からは実行させない（デモアカウントはデモ環境のseedにしか存在しない）
  def require_demo_user
    return if current_user.demo?
    render json: { error: "デモアカウントのみ実行できます" }, status: :forbidden
  end
end
