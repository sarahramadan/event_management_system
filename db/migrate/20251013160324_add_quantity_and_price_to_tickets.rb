class AddQuantityAndPriceToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :quantity, :integer
    add_column :tickets, :price, :decimal
  end
end
