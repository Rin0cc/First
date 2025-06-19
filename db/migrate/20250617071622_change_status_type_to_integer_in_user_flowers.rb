class ChangeStatusTypeToIntegerInUserFlowers < ActiveRecord::Migration[7.2]
  def change
# まず既存のstringカラムを削除
remove_column :user_flowers, :status, :string

# 再度integerで追加
add_column :user_flowers, :status, :integer, default: 0, null: false
end
end
