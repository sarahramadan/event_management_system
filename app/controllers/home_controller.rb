class HomeController < ApplicationController
  # Skip authentication for home page to allow visitors to see login/signup options
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
  end
end
