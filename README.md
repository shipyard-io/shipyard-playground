# Shipyard Playground

Minimal static service (Nginx) used to validate Shipyard Docker build/deploy flow and reusable GitHub Actions workflows.

## Tech Stack

- Nginx (`nginx:alpine`)
- Docker Compose
- GitHub Actions reusable workflows (from `shipyard-io/templates`)

## Project Structure

```text
.
├── public/
│   ├── index.html
│   └── status.json
├── docker-compose.yml
├── Dockerfile
└── .github/workflows/ci.yml
```

## Prerequisites

- Docker
- Docker Compose v2

## Environment Variables

Copy `.env.example` to `.env` and update values:

```env
APP_NAME=test-app
APP_PORT=8080
APP_DOMAIN=test.yourdomain.com
```

Variables:

- `APP_NAME`: container/service name and Traefik labels key.
- `APP_PORT`: host port mapped to container port `80`.
- `APP_DOMAIN`: domain used in Traefik router rule.

## Run Locally

1. Start service:

```bash
docker compose up -d --build
```

2. Verify container status:

```bash
docker compose ps
```

3. Validate endpoints:

- `http://localhost:<APP_PORT>/`
- `http://localhost:<APP_PORT>/status.json`

4. Stop service:

```bash
docker compose down
```

## Deployment Notes

- Image source: `ghcr.io/${GITHUB_REPOSITORY}:${IMAGE_TAG:-latest}`.
- Service joins external Docker network `proxy` (required for Traefik routing).
- Traefik labels in `docker-compose.yml` route traffic to `${APP_DOMAIN}`.

## CI/CD

Workflow file: `.github/workflows/ci.yml`

Trigger:

- Push to `develop`

Pipeline jobs:

1. Build Docker image (`reusable-build-docker.yml`)
2. Provision VPS (`reusable-provision-vps.yml`)
3. Upgrade Traefik (`reusable-upgrade-traefik.yml`)
4. Deploy via SSH (`reusable-deploy-ssh.yml`)
5. Send notification (`reusable-notify.yml`)
