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

  # Spec compatibility routes
  post "evidence", to: "evidences#create"
  get "evidence/:id", to: "evidences#show"
  post "evidence/:evidence_id/extract", to: "extraction_runs#create"
  get "evidence/:id/extract", to: "evidences#show"
  get "returns/:id/boxes", to: "boxes#index"
  patch "returns/:id/boxes/:box_definition_id", to: "boxes#update"
  get "returns/:id/checklist", to: "tax_returns#checklist"
  get "returns/:id/worksheet", to: "tax_returns#worksheet"
  get "returns/:id/export", to: "exports#legacy_export"

  resource :template_profile, only: [:show, :new, :create, :update] do
    resources :fields, controller: "template_fields", only: [:create, :update, :destroy]
  end

  resources :tax_returns, only: [:index, :create, :show] do
    member do
      get :checklist
      get :worksheet
      patch :update_calculator_settings
      patch :toggle_blind_person
      # Phase 5d: Tax Reliefs
      patch :toggle_trading_allowance
      patch :update_marriage_allowance
      patch :update_married_couples_allowance
    end

    resources :income_sources, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :pension_contributions, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :gift_aid_donations, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :field_values, only: [:index, :update]

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
