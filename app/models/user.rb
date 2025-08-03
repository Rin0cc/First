class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :user_flowers, dependent: :destroy
  has_many :records, dependent: :destroy

  # 新規作成時にusernameが必須であることを検証
  validates :username, presence: true, on: :create

  # ユーザーが作成された後に、初回のお花を自動で作成する
  after_create :create_initial_flower

  # OmniAuthでユーザーを検索または作成するメソッド
  def self.from_omniauth(auth)
    # providerとuidを使ってユーザーを検索し、存在しない場合は新規作成します。
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      # パスワードはDeviseが自動生成するランダムな文字列を設定します。
      user.password = Devise.friendly_token[0, 20]
      user.username = "名無しフラワーさん🌼"
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

  # 初回のお花を作成するメソッド
  def create_initial_flower
    default_flower = Flower.find_or_create_by(name: "コスモス")
    if default_flower.persisted?
      user_flowers.create(flower: default_flower, status: :waiting)
    end
  end
end
