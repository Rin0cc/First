class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable

  has_many :user_flowers, dependent: :destroy
  has_many :records, dependent: :destroy

  # 追加ここから
  after_create :create_initial_flower

  private

  def create_initial_flower
  user_flowers.create(status: :waiting)
  end
  # 追加ここまで
  end