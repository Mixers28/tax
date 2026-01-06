Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication routes
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "signup", to: "users#new"
  post "signup", to: "users#create"

  # Defines the root path route ("/")
  root "tax_returns#index"

  resources :tax_returns, only: [:index, :create, :show] do
    member do
      patch :update_calculator_settings
      patch :toggle_blind_person
    end

    resources :income_sources, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :pension_contributions, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :gift_aid_donations, only: [:index, :new, :create, :edit, :update, :destroy]

    resources :exports, only: [:index, :create, :show] do
      collection do
        get :review
      end
      member do
        get :download_pdf
        get :download_json
      end
    end

    resources :validations, only: [:index] do
      collection do
        post :run_validation
      end
    end
  end

  resources :evidences, only: [:new, :create, :show] do
    resources :extraction_runs, only: [:create]
  end
  resources :extraction_runs, only: [] do
    post :accept_candidate, on: :member
  end
end
