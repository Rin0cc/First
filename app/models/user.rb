class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :user_flowers, dependent: :destroy
  has_many :records, dependent: :destroy

  validates :username, presence: true, on: :create

  after_create :create_initial_flower

 def self.from_omniauth(auth)
  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
    user.email = auth.info.email
    user.password = Devise.friendly_token[0, 20]
    # 🌼 usernameの重複を防ぐため、ランダムな文字列を追加
    user.username = "名無しフラワーさん🌼#{SecureRandom.hex(3)}"
  end.tap do |user|
    unless user.persisted?
      Rails.logger.error "💥 User save failed: #{user.errors.full_messages.join(', ')}"
    end
  end
end

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
    default_flower = Flower.find_or_create_by(name: "コスモス")
    if default_flower.persisted?
      user_flowers.create(flower: default_flower, status: :waiting)
    end
  end

  def self.guest
  find_or_create_by!(email: "guest@example.com") do |user|
    user.password = SecureRandom.urlsafe_base64
    user.username = "ゲストユーザー"
  end
end
end
