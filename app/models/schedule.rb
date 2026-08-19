class Schedule < ApplicationRecord
  has_many :children
  has_many :meeting_slots

  has_many :families, through: :children
  has_many :family_unavailabilities, through: :meeting_slots

  # 今年度の計算
  def self.current_year
    today = Date.today
    # 学校は４月スタートの年度
    today.month >= 4 ? today.year : today.year-1
  end
  # 今年度はいつかDBから探す
  def self.current
    self.find_by(year: current_year)
  end
end
