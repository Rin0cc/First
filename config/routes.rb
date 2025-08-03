Rails.application.routes.draw do
  # 利用規約など静的ページ
  get "pages/terms", to: "pages#terms", as: "pages_terms"
  get "pages/privacy", to: "pages#privacy", as: "pages_privacy"

  # devise関連
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  get "/sign_up", to: redirect("/users/sign_up")

  root "top#index"

  resources :users do
    collection do
      get "ranking"
    end
  end

  # records_controller のルーティング
  resources :records, only: [ :new, :create, :update, :destroy, :index, :show ] do
    collection do
      get "analytics"
    end
  end

  resources :user_flowers, only: [ :index ] do
    collection do
      get :encyclopedia
    end
  end
  # 開発環境専用のメール確認
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
