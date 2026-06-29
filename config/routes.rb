Rails.application.routes.draw do
  # ここにはルート情報が記載できる。
  # どのメソッドでどのアクセスならここのコントローラに任せよう的なのもできる
  # またdoなどを使用して、パスを入れ子にもできるのか？
  # -> Ans: 正解。resources do ~ endでネストしたルーティングを定義できます(例: /events/1/tickets)。
  # asはどういう意味なのか？どこに影響するのか？
  # -> Ans: asはパスヘルパー名を指定します。as: :logoutでlogout_pathやlogout_urlが使えるようになります。
  # 単にup, service-workerとしている部分は何？
  # -> Ans: "up"はヘルスチェック用エンドポイント、"service-worker"と"manifest"はPWA(Progressive Web App)用のファイルです。
  resources :events
  root "welcome#index"
  get "/auth/:provider/callback" => "sessions#create"
  delete "/logout" => "sessions#destroy"

  resource :retirements, only: [ :new, :create ]

  resources :events do
    resources :tickets
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
