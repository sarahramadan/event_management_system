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

# Create admin user
admin_user = User.find_or_create_by!(email: 'admin@eventmanagement.com') do |user|
  user.name = 'System Administrator'
  user.role = 'admin'
  user.password = 'AdminPassword123!'
  user.password_confirmation = 'AdminPassword123!'
  user.confirmed_at = Time.current
  puts "Created admin user: #{user.email}"
end

if admin_user.persisted?
  puts "Admin user already exists: #{admin_user.email}"
else
  puts "Admin user created successfully: #{admin_user.email}"
end

puts "Seeds completed successfully!"