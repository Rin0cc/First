class UserFlower < ApplicationRecord
  belongs_to :user
  belongs_to :flower
  has_many :records, dependent: :destroy
end
