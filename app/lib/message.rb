class Message
  def self.not_found(record = 'record')
    "Sorry, #{record} not found."
  end

  def self.invalid_credentials
    'Invalid credentials'
  end

  def self.invalid_token
    'Invalid token'
  end

  def self.missing_token
    'Missing token'
  end

  def self.unauthorized
    'Unauthorized request'
  end

  def self.account_created
    'Account created successfully'
  end

  def self.account_not_created
    'Account could not be created'
  end

  def self.expired_token
    'Sorry, your token has expired. Please login to continue.'
  end

  def self.login_successful
    'Login successful'
  end

  def self.logged_out_successfully
    'Logged out successfully'
  end

  def self.profile_updated
    'Profile updated successfully'
  end

  def self.profile_update_failed
    'Profile update failed'
  end

  def self.password_updated
    'Password updated successfully'
  end

  def self.password_update_failed
    'Password update failed'
  end

  def self.account_deleted
    'Account deleted successfully'
  end

  def self.account_deletion_failed
    'Account deletion failed'
  end

  def self.access_denied_attendee
    'Access denied. Attendee role required.'
  end
end