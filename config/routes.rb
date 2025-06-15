Rails.application.routes.draw do
# 利用規約など静的ページ
get "pages/terms"
get "terms", to: "pages#terms"
get "privacy", to: "pages#privacy"

# devise関連
devise_for :users
get "/sign_up", to: redirect("/users/sign_up")

# トップページ
root "top#index"

# マイページ
resources :users, only: [ :show ]

# 🌱 花は裏で育てる
resources :records, only: [ :new, :create, :index, :show ]

# 開発環境専用のメール確認
mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?


get "up" => "rails/health#show", as: :rails_health_check
get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
