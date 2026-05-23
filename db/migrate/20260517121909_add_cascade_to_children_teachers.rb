class AddCascadeToChildrenTeachers < ActiveRecord::Migration[8.1]
  def change
  remove_foreign_key "children_teachers", "children"
  add_foreign_key "children_teachers", "children", on_delete: :cascade
end
end
