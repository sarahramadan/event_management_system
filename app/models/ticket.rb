# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :ticket_status
  
  validates :reference_id, presence: true, uniqueness: true
  validates :reference_code, presence: false, allow_blank: true
  validates :release_name, presence: false, allow_blank: true
  validates :purchase_date, presence: false, allow_blank: true
  
  def status_name
    ticket_status&.name
  end
  # Get ticket summary for API responses
  def ticket_summary
    {
      id: id,
      reference_id: reference_id,
      reference_code: reference_code,
      status: ticket_status.name,
      release_name: release_name,
      purchase_date: purchase_date&.iso8601,
      assigned_user: user&.email,
      created_at: created_at.iso8601,
      updated_at: updated_at.iso8601
    }
  end
end