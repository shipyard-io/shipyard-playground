# Shipyard Playground

Template ứng dụng static chạy bằng Nginx, dùng để triển khai nhanh qua Docker + GitHub Actions reusable workflows của `shipyard-io/templates`.

## Mục tiêu

- Build và push Docker image lên GHCR
- Triển khai ứng dụng lên VPS qua SSH
- Tự động cấu hình hạ tầng (VPS + Traefik) theo cờ `INIT_INFRA`
- Gửi thông báo trạng thái deploy

## Kiến trúc

- Runtime: `nginx:alpine`
- Orchestration: Docker Compose
- Reverse proxy: Traefik (network ngoài `proxy`)
- CI/CD: GitHub Actions reusable workflows

## Cấu trúc thư mục

```text
.
├── public/
│   ├── index.html
│   └── status.json
├── Dockerfile
├── docker-compose.yml
├── .env
├── .env.example
└── .github/workflows/ci.yml
```

## Biến môi trường

`docker-compose.yml` và pipeline phụ thuộc các biến sau:

- `APP_NAME`: tên ứng dụng/container (nên dùng lowercase)
- `APP_PORT`: host port map vào container port `80`
- `APP_DOMAIN`: domain route bởi Traefik
- `DOCKER_IMAGE`: image repository đầy đủ, ví dụ `ghcr.io/shipyard-io/shipyard-playground`
- `HEALTH_CHECK_PATH`: endpoint kiểm tra sau deploy, ví dụ `/`
- `INIT_INFRA`: `true|false`, bật/tắt các job setup VPS + Traefik

Ví dụ `.env`:

```env
APP_NAME=shipyard
APP_PORT=80
APP_DOMAIN=shipyard.trunganh.tech
DOCKER_IMAGE=ghcr.io/shipyard-io/shipyard-playground
HEALTH_CHECK_PATH=/
INIT_INFRA=true
```

Lưu ý:

- Trên CI, workflow `prepare` đọc `.env` từ secret `ENV_FILE_CONTENT` để lấy `APP_NAME`, `APP_DOMAIN`, `HEALTH_CHECK_PATH`, `INIT_INFRA`.
- `APP_NAME` được chuẩn hóa lowercase trong reusable workflow để đảm bảo hợp lệ khi tạo Docker image/tag.

## Chạy local

1. Cập nhật `.env` (hoặc copy từ `.env.example`).
2. Chạy:

```bash
docker compose up -d --build
```

3. Kiểm tra:

```bash
docker compose ps
curl -I http://localhost:${APP_PORT}/
curl http://localhost:${APP_PORT}/status.json
```

4. Dừng:

```bash
docker compose down
```

## CI/CD

File workflow: `.github/workflows/ci.yml`

Trigger:

- `push` vào `develop` và `main`

Luồng pipeline:

1. `prepare`
   - Parse cấu hình từ `ENV_FILE_CONTENT`
   - Export outputs dùng chung cho các job sau
2. `build`
   - Build/push image với tên app lấy từ `prepare`
3. `setup-vps` (điều kiện)
   - Chỉ chạy khi `INIT_INFRA=true`
4. `setup-traefik` (điều kiện)
   - Chạy sau `setup-vps` khi đủ điều kiện
5. `deploy`
   - Deploy image tag mới lên VPS
   - Health check theo `HEALTH_CHECK_PATH`
6. `notify`
   - Gửi trạng thái deploy

## Secrets bắt buộc

Tối thiểu cần cấu hình các secrets sau trong GitHub repository:

- `ENV_FILE_CONTENT`
- `SSH_PRIVATE_KEY`
- `SERVER_IP`
- `SERVER_USER` (optional, mặc định `ubuntu`)
- `CLOUDFLARE_ORIGIN_CERT`
- `CLOUDFLARE_ORIGIN_KEY`
- `DOMAIN`
- `TRAEFIK_DASHBOARD_AUTH`
- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_CHAT_ID`

## Lưu ý vận hành

- `docker-compose.yml` dùng network ngoài `proxy`, VPS cần có network này trước khi deploy.
- Nếu chạy nhiều app trên cùng VPS, mỗi app cần `APP_PORT` khác nhau khi vẫn publish port host.
- Khi chỉ đi qua Traefik và không cần truy cập trực tiếp qua host port, có thể bỏ `ports` sau khi điều chỉnh health check tương ứng.
