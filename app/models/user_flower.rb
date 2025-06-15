class UserFlower < ApplicationRecord
  belongs_to :user
  belongs_to :flower
  has_many :records, dependent: :destroy

  enum status: {
    none: "なし",
    seed: "種",
    sprout: "芽",
    bud: "水やり",
    full_bloom: "満開"
  }

  validate :only_one_growing_flower_per_user, on: :create

  private

  def only_one_growing_flower_per_user
    return if user.nil?

    if user.user_flowers.where.not(status: :full_bloom).exists?
      errors.add(:base, "同時に育てられる花は1つだけです。")
    end
  end
end
