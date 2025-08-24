# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
# db/seeds.rb

# Flowerモデルの初期データを設定します。
# find_or_create_by!を使用することで、データを重複して作成するのを防ぎます。
Flower.find_or_create_by!(name: "コスモス") do |flower|
  flower.bloom_image_path = "image/Flower_name1.png"
end

Flower.find_or_create_by!(name: "紫陽花") do |flower|
  flower.bloom_image_path = "FullBloom2.png"
end
