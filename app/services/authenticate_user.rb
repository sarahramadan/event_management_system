class AuthenticateUser
  def initialize(email, password)
    @email = email
    @password = password
  end

  # Service entry point
  def call
    JsonWebToken.encode(user_id: user.id) if user
  end

  private

  attr_reader :email, :password

  # Verify user credentials
  def user
    user = User.find_by(email: email)
    
    # Check if user exists and password is valid
    unless user&.valid_password?(password)
      raise(ExceptionHandler::AuthenticationError, Message.invalid_credentials)
    end
    
    # Check if attendee is confirmed
    unless user.confirmed?
      raise(ExceptionHandler::AuthenticationError, Message.account_not_confirmed)
    end
    
    user
  end
end