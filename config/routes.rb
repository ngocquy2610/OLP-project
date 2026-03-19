Rails.application.routes.draw do
  get "about", to: "pages#about", as: "about"
  get "show",  to: "profiles#show"
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
  resources :courses, only: [ :index, :show ]
  namespace :management do
    resources :courses
    resources :topics
    resources :lessons
    resources :exams
    resources :practices
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
