# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :ticket_status
  
  validates :reference_id, presence: true, uniqueness: true
  validates :reference_code, presence: false, allow_blank: true
  validates :release_name, presence: false, allow_blank: true
  validates :purchase_date, presence: false, allow_blank: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

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
      quantity: quantity,
      price: price.to_f,
      total_amount: (quantity * price).to_f,
      purchase_date: purchase_date&.iso8601,
      assigned_user: user&.email,
      created_at: created_at.iso8601,
      updated_at: updated_at.iso8601
    }
  end
  
  def total_amount
    quantity * price
  end
end