class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
         
  # Define user roles using enum
  enum role: {
    attendee: 1,
    admin: 2
  }
  
  # Set default role after creation
  after_initialize :set_default_role, if: :new_record?
  
  # Role helper methods
  def admin?
    role == 'admin'
  end
  
  def attendee?
    role == 'attendee'
  end
  
  private
  
  def set_default_role
    self.role ||= :attendee
  end
end
