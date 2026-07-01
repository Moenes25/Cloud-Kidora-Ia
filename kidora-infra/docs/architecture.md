# 🏗️ Kidora Architecture

## System Design

Kidora runs on a **single Hetzner Cloud server** with a modular Docker Compose stack.

## Components

### 1. Traefik (Reverse Proxy)
- Handles SSL termination via Let's Encrypt
- Routes traffic to backend/frontend/monitoring services
- Dashboard at `https://traefik.YOUR_DOMAIN`

### 2. PostgreSQL
- Primary database for the Kidora application
- Data persisted on `/mnt/data` (Hetzner volume)
- Exposed only on localhost:5432
- Automatic health checks

### 3. MinIO
- Object storage for file uploads (images, documents)
- S3-compatible API
- Console at port 9001 (localhost only)

### 4. Backend (Spring Boot)
- Java/Spring Boot application
- Connects to PostgreSQL and MinIO
- Exposed via Traefik at `https://api.YOUR_DOMAIN`

### 5. Frontend (React/Vue)
- SPA served via Nginx
- Proxies API calls to backend
- Served via Traefik at `https://YOUR_DOMAIN`

### 6. Monitoring Stack (Production only)
- **Prometheus**: Metrics collection & alerting
- **Grafana**: Dashboards & visualization
- **Loki + Promtail**: Log aggregation
- **Alertmanager**: Alert routing (email, Slack, etc.)

## Storage Layout

| Mount Point | Volume | Purpose |
|------------|--------|---------|
| `/mnt/data/postgres` | Data volume | Database files |
| `/mnt/data/minio` | Data volume | Object storage |
| `/mnt/data/uploads` | Data volume | App uploads |
| `/mnt/data/prometheus` | Data volume | Metrics |
| `/mnt/data/grafana` | Data volume | Grafana state |
| `/mnt/data/loki` | Data volume | Logs |
| `/mnt/backup/postgres` | Backup volume | DB dumps |
| `/mnt/backup/uploads` | Backup volume | File backups |

## Network

- **Public**: Ports 80 (HTTP) and 443 (HTTPS) open to internet
- **Internal**: Services communicate via Docker bridge network
- **Database & MinIO**: Exposed only on 127.0.0.1 for direct management

## Server Sizing

| Server Type | vCPU | RAM | SSD | Recommended For |
|------------|------|-----|-----|-----------------|
| CX22 | 2 | 4GB | 40GB | Small deployments |
| CX32 | 4 | 8GB | 80GB | Medium deployments |
| CX42 | 8 | 16GB | 160GB | Heavy load |