class RemoveUserFromFamilies < ActiveRecord::Migration[8.1]
  def change
    # 元々 user_id を削除する内容だったが、Family belongs_to :user のため
    # user_id は必須カラム。誤って作成されたマイグレーションのため何もしない。
  end
end
