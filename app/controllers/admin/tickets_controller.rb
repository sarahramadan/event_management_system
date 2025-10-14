class Admin::TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :find_ticket, only: [:show, :destroy]

  def index
    @filter_params = filter_parameters
    tickets_scope = build_tickets_query
    
    # Simple pagination without Pagy for now
    @page = params[:page]&.to_i || 1
    @per_page = 5
    @offset = (@page - 1) * @per_page
    
    @total_tickets = tickets_scope.count
    @tickets = tickets_scope.limit(@per_page).offset(@offset)
    @total_pages = (@total_tickets.to_f / @per_page).ceil
    
    @status_options = TicketStatus.pluck(:name, :name)
  end

  def show
  end

  def destroy
    ticket_reference = @ticket.reference_code
    
    if @ticket.soft_delete
      redirect_to admin_tickets_path, notice: "Ticket ##{ticket_reference} was successfully deleted."
    else
      redirect_to admin_tickets_path, alert: 'Unable to delete ticket.'
    end
  end

  private

  def build_tickets_query  
    scope = Ticket.includes(:user, :ticket_status).order(created_at: :desc)
    
    scope = apply_search_filter(scope) if @filter_params[:search].present?
    scope = apply_status_filter(scope) if @filter_params[:status].present?
    
    scope
  end

  def apply_search_filter(scope)
    search_pattern = "%#{@filter_params[:search]}%"
    scope.joins(:user).where(
      "users.name ILIKE ? OR users.email ILIKE ? OR tickets.reference_code ILIKE ?",
      search_pattern, search_pattern, search_pattern
    )
  end

  def apply_status_filter(scope)
    return scope if @filter_params[:status] == 'all'
    
    scope.joins(:ticket_status).where(ticket_statuses: { name: @filter_params[:status] })
  end

  def filter_parameters
    {
      search: params[:search]&.strip,
      status: params[:status]&.strip
    }
  end

  def find_ticket
    @ticket = Ticket.unscoped.find(params[:id])

    if @ticket.deleted_at.present?
      redirect_to admin_tickets_path, notice: 'Ticket does not exist or has been deleted'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_tickets_path, alert: 'Requested ticket could not be found'
  end
end