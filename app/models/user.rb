class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_flowers, dependent: :destroy
  has_many :records, dependent: :destroy

  after_create :create_initial_flower

  def first_record_date
    records.order(created_at: :asc).first&.created_at&.in_time_zone("Asia/Tokyo")&.to_date
  end

  def days_since_first_record
    first_date = first_record_date
    return 0 unless first_date
    (Date.current - first_date).to_i + 1
  end

  def total_record_duration_hours
    total_seconds = records.sum(:time)
    (total_seconds / 3600.0).round(1)
  end

  private

  def create_initial_flower
    default_flower = Flower.first # または Flower.find_by(name: "コスモス") など、適切な花を選択
    user_flowers.create(flower: default_flower, status: :waiting) if default_flower
  end
end