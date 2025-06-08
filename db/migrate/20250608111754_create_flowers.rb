class CreateFlowers < ActiveRecord::Migration[7.2]
  def change
    create_table :flowers do |t|
      t.string :name
      t.string :bloom_image_path

      t.timestamps
    end
  end
end
