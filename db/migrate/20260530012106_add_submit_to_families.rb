class AddSubmitToFamilies < ActiveRecord::Migration[8.1]
  def change
    add_column :families, :submitted, :boolean
  end
end
