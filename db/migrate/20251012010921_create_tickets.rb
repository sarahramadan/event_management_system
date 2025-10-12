class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.string :reference_id, null: false
      t.references :user, null: true, foreign_key: { on_delete: :restrict }
      t.references :ticket_status, null: true, foreign_key: { on_delete: :nullify }
      t.datetime :purchase_date
      t.string :release_name

      t.timestamps
    end
    
    add_index :tickets, :reference_id, unique: true
    add_index :tickets, [:user_id, :ticket_status_id]
    add_index :tickets, :purchase_date
  end
end
