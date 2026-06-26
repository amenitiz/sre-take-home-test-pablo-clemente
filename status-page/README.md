# Status Page

A simple Rails application that displays the operational status of services. This is used as part of the Amenitiz infrastructure take-home challenge.

## Prerequisites

- Ruby 3.3.6
- PostgreSQL 16+
- Or just Docker

## Local Development

### With Docker Compose

```bash
docker compose up --build
```

The app will be available at http://localhost:3000.

### Without Docker

```bash
bundle install
rails db:prepare
rails db:seed
rails server
```

## Endpoints

- `/` - Service status dashboard
- `/services` - CRUD interface for managing services
- `/healthz` - JSON health check endpoint (returns database connectivity status)
- `/up` - Rails built-in health check
