# Docker Setup Instructions

This Rails application has been configured to run with Docker and PostgreSQL.

## Prerequisites

- Docker
- Docker Compose

## Getting Started

1. **Build and start the application:**
   ```bash
   docker-compose up --build
   ```

2. **The application will be available at:**
   - Rails app: http://localhost:3000
   - PostgreSQL: localhost:5432

## Environment Variables

The following environment variables are configured in docker-compose.yml:

- `DB_HOST=db` - PostgreSQL service name
- `DB_USERNAME=postgres` - Database username
- `DB_PASSWORD=password` - Database password
- `DB_NAME=event_management_system_development` - Database name

## Common Commands

**Start services:**
```bash
docker-compose up
```

**Stop services:**
```bash
docker-compose down
```

**Rebuild and start:**
```bash
docker-compose up --build
```

**Run Rails commands:**
```bash
# Generate migration
docker-compose exec web rails generate migration CreateUsers

# Run migrations
docker-compose exec web rails db:migrate

# Open Rails console
docker-compose exec web rails console

# Run tests
docker-compose exec web rails test
```

**Database commands:**
```bash
# Create database
docker-compose exec web rails db:create

# Setup database (create + migrate + seed)
docker-compose exec web rails db:setup

# Reset database
docker-compose exec web rails db:reset

# Access PostgreSQL directly
docker-compose exec db psql -U postgres -d event_management_system_development
```

**View logs:**
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs web
docker-compose logs db
```

## Production Deployment

For production, create a `docker-compose.prod.yml` file with:
- Proper environment variables
- Volume mounts for persistent data
- Reverse proxy configuration
- SSL certificates

## Troubleshooting

**Database connection issues:**
- Ensure PostgreSQL service is healthy: `docker-compose ps`
- Check logs: `docker-compose logs db`

**Permission issues:**
- Rebuild the image: `docker-compose build --no-cache`

**Port conflicts:**
- Change port mappings in docker-compose.yml if 3000 or 5432 are in use