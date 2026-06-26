services = [
  { name: "Web Application", url: "https://app.example.com", status: "operational", description: "Main customer-facing application" },
  { name: "API", url: "https://api.example.com", status: "operational", description: "Public REST API" },
  { name: "Database", url: "postgres://db.internal:5432", status: "operational", description: "Primary PostgreSQL database" },
  { name: "Background Jobs", url: "https://app.example.com/sidekiq", status: "operational", description: "Async job processing" },
  { name: "CDN", url: "https://cdn.example.com", status: "operational", description: "Static asset delivery" }
]

services.each do |attrs|
  Service.find_or_create_by!(name: attrs[:name]) do |s|
    s.url = attrs[:url]
    s.status = attrs[:status]
    s.description = attrs[:description]
  end
end

puts "Seeded #{Service.count} services."
