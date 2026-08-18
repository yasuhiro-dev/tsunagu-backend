class AddDefaultToFamiliesSubmitted < ActiveRecord::Migration[8.0]
  def up
    # nilからfalseに変える（デフォルト値を設定）
    change_column_default :families, :submitted, from: nil, to: false
    # すでにDBにあるものを全てfalseに変更する
    Family.where(submitted: nil).update_all(submitted: false)
    # NULLという値を入れることを許可しない
    change_column_null :families, :submitted, false
  end

  # def upの変更を戻す時
  def down
    change_column_null :families, :submitted, true
    change_column_default :families, :submitted, from: false, to: nil
  end
end
