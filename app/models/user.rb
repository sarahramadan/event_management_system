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
  
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validate :admin_limit, if: :admin?
  
  # Role helper methods
  def admin?
    role == 'admin'
  end
  
  def attendee?
    role == 'attendee'
  end
  
  # Class method to check if admin registration is allowed
  def self.admin_registration_allowed?
    # Allow admin registration if there are fewer than 5 admins
    # You can adjust this limit or add environment variable control
    admin.count < (ENV['MAX_ADMINS']&.to_i || 5)
  end
  
  private
  
  def set_default_role
    self.role ||= :attendee
  end
  
  def admin_limit
    if admin? && new_record? && !User.admin_registration_allowed?
      errors.add(:role, "Admin registration is currently limited. Contact system administrator.")
    end
  end
end
