class UserFlower < ApplicationRecord
  belongs_to :user
  belongs_to :flower
end
