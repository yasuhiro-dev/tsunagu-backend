class CreateChildren < ActiveRecord::Migration[8.1]
  def change
    create_table :children do |t|
      t.string :name
      t.references :family, null: false, foreign_key: true
      t.timestamps
    end
  end
end
