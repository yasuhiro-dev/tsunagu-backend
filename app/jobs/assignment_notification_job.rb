class AssignmentNotificationJob < ApplicationJob
  queue_as :default
  # Gmail API 側の一時的な失敗の時だけ再試行する。（最大３回までリトライするたびにだんだん時間が伸びていく）
  # Google未連携の場合はここに含めず、failed_executions に落として可視化する。
  retry_on OAuth2::Error, Faraday::Error, wait: :polynomially_longer, attempts: 3

  def perform(dry_run: false) # 初期値はfalseで試運転
  AssignmentNotifier.new.call(dry_run: dry_run) # デモアカウントであればfalse、本番のアカウントならtrueという情報をコントローラーから受け取る
  end
end
