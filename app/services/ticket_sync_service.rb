# app/services/ticket_sync_service.rb
class TicketSyncService
  def initialize(ticket_data)
    @data = ticket_data
  end

  def ticket_sync
    ActiveRecord::Base.transaction do
      # --- Update user ---
     user = user_sync
     return unless user

      # --- Sync ticket ---
      ticket = Ticket.find_or_initialize_by(reference_id: @data['id'], user_id: user.id)
      ticket_status = TicketStatus.find_by!(name: @data['state'] || @data['state_name'])

      ticket.assign_attributes(
        reference_id: @data['id'],
        reference_code: @data['reference'],
        ticket_status: ticket_status,
        purchase_date: parse_date(@data['created_at']),
        release_name: @data['release_title'],
        quantity: @data['quantity'] || 1,
        price: @data['price'].to_f,
        user: user
      )

      ticket.save!
      Rails.logger.info "Ticket #{ticket.reference_id} synced for user #{user.email}"
    end

  rescue => e
    Rails.logger.error "Ticket sync failed: #{e.message}"
  end

  def user_sync
    user = User.find_by(email: @data['email'], role: 'attendee')

    unless user
      Rails.logger.warn "No user found for email: #{@data['email']}, skipping ticket sync"
      return
    end  

    user.update!(
        name: @data['name'].strip,
        phone_number: @data['phone_number']
    )
    user
  rescue => e
    Rails.logger.error "User sync failed: #{e.message}"
    raise
  end

  def parse_date(value)
    Time.zone.parse(value) rescue nil
  end
end
