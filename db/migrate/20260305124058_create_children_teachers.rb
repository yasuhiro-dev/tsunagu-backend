class CreateChildrenTeachers < ActiveRecord::Migration[8.1]
  def change
    create_table :children_teachers do |t|
      t.references :child, null: false, foreign_key: true
      t.references :teacher, null: false, foreign_key: true

      t.timestamps
    end
  end
end
