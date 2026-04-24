class AddUserIdToFamilies < ActiveRecord::Migration[8.1]
  def change
    add_column :families, :user_id, :integer
  end
end
