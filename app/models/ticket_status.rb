# frozen_string_literal: true

class TicketStatus < ApplicationRecord
  has_many :tickets, dependent: :nullify
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
end