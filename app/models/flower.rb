class Flower < ApplicationRecord
  has_many :user_flowers, dependent: :destroy

  validates :name, presence: true
end
