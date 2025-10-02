class Flower < ApplicationRecord
  has_many :user_flowers, dependent: :destroy

  validates :name, presence: true

  # 画像パスを安全に扱うメソッド
  def bloom_image_path
    path = self[:bloom_image_path] # DBに保存されている値を直接参照
    return "placeholder_flower.png" if path.blank?

    # "image/" がついていたら除去して返す
    path.sub(/^image\//, "")
  end
end
