class ConfirmExistingUsers < ActiveRecord::Migration[7.1]
  def up
    # Confirm all existing users so they can continue to log in
    User.update_all(confirmed_at: Time.current)
  end

  def down
    # Optionally remove confirmation for all users if rolling back
    User.update_all(confirmed_at: nil)
  end
end
