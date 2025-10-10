Rails.application.routes.draw do
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
    resources :users, only: [:index, :show, :edit, :update, :destroy]
  end

  # API routes
  namespace :api do
    namespace :v1 do
      # Status endpoint
      get 'status', to: 'status#index'
      
      # Examples endpoint
      get 'examples', to: 'examples#index'
      
      # Authentication routes
      post 'auth/login', to: 'sessions#create'
      delete 'auth/logout', to: 'sessions#destroy'
      
      # Registration routes
      post 'attendees/register', to: 'registrations#create'
      
      # Profile management routes
      get 'profile', to: 'profile#show'
      put 'profile', to: 'profile#update'
      patch 'profile', to: 'profile#update'
      delete 'profile', to: 'profile#destroy'
      put 'profile/password', to: 'profile#update_password'
    end
  end

  # Health check for load balancers and uptime monitors
  get "up" => "rails/health#show", as: :rails_health_check

  # Error handling routes
  get '/404', to: 'errors#not_found'
  get '/422', to: 'errors#unprocessable_entity'
  get '/500', to: 'errors#internal_server_error'

  # Catch-all route for undefined paths (must be last)
  match '*path', to: 'errors#not_found', via: :all
end
