Rails.application.routes.draw do
  get "carts/show"
  get "about", to: "pages#about", as: "about"
  get "show",  to: "profiles#show"
  get "cart_items", to: "cart_items#create", as: "add_to_cart"
  get 'teacher/dashboard', to: 'teacher_dashboards#index', as: :teacher_dashboard
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  root "application#home"
  resource :profile, only: [ :show, :edit, :update ]
  resources :courses, only: [ :index, :show ] do
    collection do
      get :my_courses
    end
    member do
      get :learn
    end
    resources :feedback_courses, only: [:index, :create, :edit, :update]
  end

  resources :feedback_courses, only: [] do
    resource :like, only: [:create, :destroy] 
  end

  resource :cart, only: [ :show ]
  resources :cart_items, only: [ :create, :destroy ]
  namespace :management do
    resources :courses
    resources :topics
    resources :lessons
    resources :exams
    resources :practices
  end
  resources :orders do
    member do
      get :gmo_checkout
      post :checkout
      post :charge_gmo
      get :success
      get :cancel
    end
  end
  resource :cart do
    post :checkout
    post :apply_voucher
    post :validate_voucher
    post :remove_voucher
    delete :remove_voucher
  end

  resources :topics do
    member do
      get :exam
      post :submit_exam
    end
  end

  resources :lessons do
    member do
      get :practice
      post :submit_practice
    end
  end

  resources :orders, only: [:index, :show] do
    member do
      get :invoice #invoice_order_path
    end
  end

  namespace :admin do
    get 'dashboard', to: 'dashboards#index'
    get 'management', to: 'management#index'
    delete 'management/:id', to: 'management#destroy', as: 'management_destroy'
    patch 'management/:id', to: 'management#update', as: 'management_update'

    resources :courses, only: [:index, :show] do
      member do
        patch :published
        patch :rejected
      end
      
    end
    resources :vouchers
  end

  resources :withdrawals, only: [:create]
  resources :stripe_connects, only: [:create] do
    collection do
      get :return
      get :refresh
    end
  end
end
