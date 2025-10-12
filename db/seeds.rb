# db/seeds.rb

puts "Seeding ticket statuses..."

statuses = [
  { name: "complete",   description: "Ticket fully processed and assigned" },
  { name: "incomplete", description: "Ticket created but missing data" },
  { name: "unassigned", description: "Ticket not linked to any user" },
  { name: "void",       description: "Ticket canceled or invalid" }
]

statuses.each do |status|
  TicketStatus.find_or_create_by!(name: status[:name]) do |s|
    s.description = status[:description]
  end
end

puts "✅ Ticket statuses seeded successfully!"