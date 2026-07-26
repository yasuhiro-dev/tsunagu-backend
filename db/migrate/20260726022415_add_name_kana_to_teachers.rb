class AddNameKanaToTeachers < ActiveRecord::Migration[8.1]
  def change
    add_column :teachers, :name_kana, :string
  end
end
