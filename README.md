# Infrastructure Take-Home Challenge

Hi! See [CHALLENGE.md](CHALLENGE.md) for the full instructions.

## Quick Start (Local Development)

The `status-page/` directory contains a Rails application. To run it locally:

```bash
cd status-page

# Start PostgreSQL
docker compose up -d

# Install dependencies and set up the database
bundle install
bin/rails db:prepare

# Run the tests
bin/rails test

# Run the app
bin/rails server
```

The app will be available at `http://localhost:3000`.

See `.env.example` in `status-page/` for production environment variables.
