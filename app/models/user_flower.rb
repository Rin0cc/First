class UserFlower < ApplicationRecord
  belongs_to :user
  belongs_to :flower
  has_many :records, dependent: :destroy

  enum status: {
    waiting: 0 ,# 待機中,
    seed: 1 ,#種,
    sprout: 2, #"芽",
    bud: 3, #"水やり",
    full_bloom: 4 ,#"満開"
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
