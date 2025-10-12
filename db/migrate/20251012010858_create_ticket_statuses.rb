class CreateTicketStatuses < ActiveRecord::Migration[7.1]
  def change
    create_table :ticket_statuses do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
    
    add_index :ticket_statuses, :name, unique: true
  end
end
