Rails.application.routes.draw do
  # 利用規約など静的ページ
  get "pages/terms", to: "pages#terms", as: "pages_terms"
  get "pages/privacy", to: "pages#privacy", as: "pages_privacy"

  # devise関連
  devise_for :users
  get "/sign_up", to: redirect("/users/sign_up")

  # --- ここから修正 ---

  # アプリのトップページは top#index のまま
  root "top#index"
  # previous line: root "records#new" があった場合は削除済みです

  # マイページ
  resources :users, only: [ :show ]

  # ToDo機能と時間記録のためのルーティング
  # new, create に加えて、update (ToDoの完了/編集用), destroy (ToDo削除用) も含めます
  # user_flowers にネストしない独立した records ルーティングを使います
  # これにより、/records/new, /records (POST), /records/:id (PATCH), /records/:id (DELETE) が生成されます。
  resources :records, only: [ :new, :create, :update, :destroy, :index ] 

  # user_flowers にネストした records ルーティングは、
  # 今回のメインフロー（/records/new）では使わないので削除またはコメントアウトします。
  # もし将来的に user_flowers ごとに記録を管理する機能が必要になったら復活させましょう。
  # resources :user_flowers do
  #   resources :records, only: [ :new, :create ]
  # end

  # --- ここまで修正 ---

  # 開発環境専用のメール確認
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end