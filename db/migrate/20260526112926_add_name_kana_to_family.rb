class AddNameKanaToFamily < ActiveRecord::Migration[8.1]
  def change
    add_column :families, :name_kana, :string
  end
end
