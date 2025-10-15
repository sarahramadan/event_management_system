Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  
  # Mount letter_opener_web for development email viewing
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  
  # Default Devise routes for users (login, password reset, etc.)
  # Skip registrations since we use custom admin registration and API for regular users
  devise_for :users, controllers: {
    sessions: 'sessions'
  }, skip: [:registrations]
  
  # Custom registration routes for admin
  get '/admin/sign_up', to: 'admin_registrations#new', as: 'new_admin_registration'
  post '/admin/sign_up', to: 'admin_registrations#create', as: 'admin_registration'
  
  # Root route
  root "home#index"
  
  # Admin routes - accessible only to admin users
  namespace :admin do
    root 'dashboard#index'
    resources :tickets, only: [:index, :show, :destroy]
    resources :users, only: [:index, :show]
    resource :environment_variables, only: [:show], controller: 'environment_variables'
  end

  # API routes
  namespace :api do
    namespace :v1 do   
      # Authentication routes
      post 'auth/login', to: 'sessions#create'
      delete 'auth/logout', to: 'sessions#destroy'
      
      # Registration routes
      post 'register', to: 'registrations#create'
      
      # Profile management routes
      get 'profile', to: 'profile#show'

      # Ticket routes
      resources :tickets, only: [:show]

      # Tito webhook endpoint
      post 'webhook', to: 'tito_webhooks#receive'

      # Tito API integration routes
      get 'tito/test_connection', to: 'tito#test_connection'
      get 'tito/attendee_tickets', to: 'tito#attendee_tickets'
    end
  end

  # Health check for load balancers and uptime monitors
  get "up" => "rails/health#show", as: :rails_health_check

  # Error handling routes
  get '/404', to: 'errors#not_found'
  get '/422', to: 'errors#unprocessable_entity'
  get '/500', to: 'errors#internal_server_error'

 # Catch-all route for undefined non-API paths
  match '*path', to: 'errors#not_found', via: :all,
        constraints: lambda { |req| !req.path.start_with?('/api') }
end
