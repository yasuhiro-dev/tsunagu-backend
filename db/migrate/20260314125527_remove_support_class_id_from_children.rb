class RemoveSupportClassIdFromChildren < ActiveRecord::Migration[8.1]
  def change
    remove_column :children, :support_class_id, :integer
  end
end
