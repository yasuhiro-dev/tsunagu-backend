class AddUserIdToTeachers < ActiveRecord::Migration[8.1]
  def change
    add_column :teachers, :user_id, :integer
  end
end
