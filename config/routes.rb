Rails.application.routes.draw do
  get "pages/terms"
  get "records/new"
  get "records/create"
  devise_for :users
  get "/sign_up", to: redirect("/users/sign_up")

  # 開発環境のみ LetterOpener を有効
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # ヘルスチェック & PWA
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "terms", to: "pages#terms"
  get "privacy", to: "pages#privacy"
  # トップページ
  root "top#index"

  # ユーザーのマイページ表示
  resources :users, only: [ :show ]

  # 花ごとの記録（ネスト構造）
  resources :user_flowers do
    resources :records, only: [ :new, :create ]
  end
end
