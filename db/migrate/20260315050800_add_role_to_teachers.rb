class AddRoleToTeachers < ActiveRecord::Migration[8.1]
  def change
    add_column :teachers, :role, :integer
  end
end
