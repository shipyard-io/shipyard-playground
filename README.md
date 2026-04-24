# Shipyard-playground Test

Demo project to test Docker build/deploy flow and reusable GitHub Actions workflows.

## Requirements

- Docker
- Docker Compose

## Quick Start

1. Update `.env` values if needed.
2. Build and run:

```bash
docker compose up -d --build
```

3. Check running containers:

```bash
docker compose ps
```

4. Stop services:

```bash
docker compose down
```

## Environment

Main variables in `.env`:

- `APP_NAME`
- `APP_PORT`
- `APP_DOMAIN`

Use `.env.example` as a template when creating a new environment file.

## CI

CI workflow is defined in `.github/workflows/ci.yml` and currently targets `develop` branch pushes for testing.
