class AddSupportClassIdToChild < ActiveRecord::Migration[8.1]
  def change
    add_column :children, :support_class_id, :integer
  end
end
