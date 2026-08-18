class AddDefaultToMeetingSlotsStatus < ActiveRecord::Migration[8.0]
  def up
    # nillからavailableに変える（デフォルト値を設定）
    change_column_default :meeting_slots, :status, from: nil, to: 0
    # すでにDBにあるものを全てavailableに変更する
    MeetingSlot.where(status: nil).update_all(status: 0)
    # NULLという値を入れることを許可しない
    change_column_null :meeting_slots, :status, false
  end

  def down
    change_column_null :meeting_slots, :status, true
    change_column_default :meeting_slots, :status, from: 0, to: nil
  end
end
