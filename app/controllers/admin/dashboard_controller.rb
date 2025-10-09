class Admin::DashboardController < ApplicationController
  before_action :require_admin!
  
  def index
    @total_users = User.count
    @total_admins = User.admin.count
    @total_attendees = User.attendee.count
    @recent_users = User.order(created_at: :desc).limit(5)
  end
end
