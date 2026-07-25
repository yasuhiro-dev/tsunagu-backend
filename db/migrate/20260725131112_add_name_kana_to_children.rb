class AddNameKanaToChildren < ActiveRecord::Migration[8.1]
  def change
    add_column :children, :name_kana, :string
  end
end
