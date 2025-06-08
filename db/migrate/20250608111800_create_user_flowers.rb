class CreateUserFlowers < ActiveRecord::Migration[7.2]
  def change
    create_table :user_flowers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :flower, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
