FactoryBot.define do
  factory :user do
    # name ではなく username に変更！
    # username はユニークにする必要があるため、sequence を使うのがおすすめです
    sequence(:username) { |n| "testuser#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    # admin カラムは存在しないので削除
    # admin { false }
    # trait :admin do
    #   admin { true }
    # end

    # invalid_user ファクトリも username に合わせる
    factory :invalid_user do
      username { nil } # username がないユーザー
      email { "invalid@example.com" }
    end
  end

  # Flower モデルのファクトリも追加してみましょう
  factory :flower do
    sequence(:name) { |n| "ひまわり#{n}" }
    bloom_image_path { "images/sunflower_bloom.png" }
    growth_image_path { "images/sunflower_growth.png" }
  end

  # UserFlower モデルのファクトリも追加してみましょう
  factory :user_flower do
    association :user    # 関連する User を自動で作成
    association :flower  # 関連する Flower を自動で作成
    status { 0 }         # デフォルト値
  end

  # Record モデルのファクトリも追加してみましょう
  factory :record do
    association :user
    association :user_flower
    task_name { "水やり" }
    time { 30 }
    completed { false }
  end
end
