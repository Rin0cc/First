class Flower < ApplicationRecord
  has_many :user_flowers, dependent: :destroy

  validates :name, presence: true

  def bloom_image_path
    path = self[:bloom_image_path]

    # 💡 修正: パスが空の場合、存在するデフォルト画像（FullBloom1.png）を返す
    return "FullBloom1.png" if path.blank?

    path.sub(/^image\//, "")
  end
end
