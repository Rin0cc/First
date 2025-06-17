class AddGrowthImagePathToFlowers < ActiveRecord::Migration[7.2]
  def change
    add_column :flowers, :growth_image_path, :string
  end
end
