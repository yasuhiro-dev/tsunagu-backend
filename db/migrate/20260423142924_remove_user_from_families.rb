class RemoveUserFromFamilies < ActiveRecord::Migration[8.1]
  def change
    remove_column :families, :user, :integer
  end
end
