class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2] # ここに:omniauthableとomniauth_providersを追加

  has_many :user_flowers, dependent: :destroy
  has_many :records, dependent: :destroy

  # Userが作成された後に初回のお花を作成する
  # ただし、OmniAuthで作成される場合は from_omniauth で処理されるため、
  # こちらは通常のユーザー登録の場合にのみ適用される
  after_create :create_initial_flower, if: -> { provider.nil? } # OmniAuthユーザーには適用しないように条件を追加

  # OmniAuthでユーザーを検索または作成するメソッド
  # ユーザー名は反映させないため、nameは設定しない
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      # user.name = auth.info.name # ここをコメントアウトすることで、ユーザー名は反映させない
      
      # OmniAuthでユーザーを作成する際に、初回のお花も作成
      # Flowerがまだ存在しない場合も考慮して Flower.first_or_create を使用
      default_flower = Flower.first_or_create(name: "ひまわり")
      user.user_flowers.build(flower: default_flower, status: :waiting) if default_flower.persisted?
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
    # ここも from_omniauth と同様に Flower.first_or_create を使用することで、
    # Flowerレコードが存在しない場合にも対応できます
    default_flower = Flower.first_or_create(name: "ひまわり")
    user_flowers.create(flower: default_flower, status: :waiting) if default_flower.persisted?
  end
end
