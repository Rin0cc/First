class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable

  has_many :user_flowers, dependent: :destroy
  has_many :records, dependent: :destroy

  after_create :create_initial_flower

  private

  def create_initial_flower
    default_flower = Flower.first # または Flower.find_by(name: "コスモス") など
    user_flowers.create(flower: default_flower, status: :waiting) if default_flower
  end
end
