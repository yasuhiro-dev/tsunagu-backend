class CreateFamilyUnavailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :family_unavailabilities do |t|
      t.references :family, null: false, foreign_key: true
      t.references :interview_slot, null: false, foreign_key: true

      t.timestamps
    end
  end
end
