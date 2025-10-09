Rails.application.routes.draw do
  devise_for :users
  
  # Root route
  root "home#index"
  
  # Admin routes - accessible only to admin users
  namespace :admin do
    root 'dashboard#index'
    resources :users, only: [:index, :show, :edit, :update, :destroy]
  end

  # Health check for load balancers and uptime monitors
  get "up" => "rails/health#show", as: :rails_health_check
end
