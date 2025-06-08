class CreateRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :records do |t|
      t.references :user, null: false, foreign_key: true
      t.references :user_flower, null: false, foreign_key: true
      t.text :task_name

      t.timestamps
    end
  end
end
