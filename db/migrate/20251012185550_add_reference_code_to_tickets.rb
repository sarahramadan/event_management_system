class AddReferenceCodeToTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :tickets, :reference_code, :string
    add_index :tickets, :reference_code
  end
end
