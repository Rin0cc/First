class UserFlower < ApplicationRecord
  belongs_to :user
  belongs_to :flower
  has_many :records, dependent: :destroy

  enum status: {
  seed: "種",
  sprout: "芽",
  bud: "水やり",
  full_bloom: "満開"
  }

validate :only_one_growing_flower_per_user, on: :create

private

   # 同時に育てている花があればNG（満開以外が育成中とみなす）
   def only_one_growing_flower_per_user
    if user.user_flowers.where.not(status: "full_bloom").exists?
      errors.add(:base, "同時に育てられる花は1つだけです。")
    end
  end
end
