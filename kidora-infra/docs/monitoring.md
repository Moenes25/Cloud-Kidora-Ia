# 📊 Monitoring Guide

## Overview

The monitoring stack (production only) provides:

- **Metrics**: Prometheus collects CPU, memory, disk, and custom app metrics
- **Logs**: Loki + Promtail aggregate logs from all containers
- **Dashboards**: Grafana visualizes everything in customizable dashboards
- **Alerts**: Alertmanager sends notifications via email/Slack/webhook

## Access

| Service | URL | Credentials |
|---------|-----|-------------|
| Grafana | `https://grafana.YOUR_DOMAIN` | admin / {from Ansible vault} |
| Prometheus | `https://prometheus.YOUR_DOMAIN` | (no auth, internal) |
| Alertmanager | `https://alertmanager.YOUR_DOMAIN` | (no auth, internal) |

## Grafana Dashboards

Pre-configured dashboards (if provisioned via `./grafana/dashboards/`):

1. **Docker Containers** - Container resource usage
2. **PostgreSQL** - Database performance metrics
3. **Application Metrics** - Backend JVM metrics (if exposed via Spring Actuator)
4. **Logs Explorer** - Search through all container logs

## Alerts (Alertmanager)

Default alert rules in `monitoring/prometheus/rules/`:

| Alert Name | Condition | Severity |
|-----------|-----------|----------|
| HighCPUUsage | CPU > 80% for 5min | warning |
| HighMemoryUsage | Memory > 85% for 5min | warning |
| DiskFull | Disk usage > 90% | critical |
| ServiceDown | Container not running for 1min | critical |
| HighErrorRate | HTTP 5xx > 5% for 5min | warning |

## Log Aggregation

### Loki

All Docker container logs are automatically shipped to Loki via the `loki` logging driver (configured in `docker-compose.prod.yml`).

### Querying Logs

In Grafana Explore (Loki data source):

```logQL
# All logs from backend
{container="kidora-backend"}

# Error logs from any container
{container=~".+"} |= "ERROR"

# Specific time range
{container="kidora-postgres"} |= "FATAL"
```

## Prometheus Configuration

Main config file: `monitoring/prometheus/prometheus.yml`

Scrapes:
- `cadvisor` (if added) - Container metrics
- `node_exporter` (if added) - Host metrics
- Backend `/actuator/prometheus` - Spring Boot metrics

## Custom Metrics

To expose custom metrics from the Spring Boot backend:

1. Add `micrometer-registry-prometheus` dependency
2. Configure `management.endpoints.web.exposure.include=health,info,prometheus`
3. Add the backend as a Prometheus target in `prometheus.yml`

## Retention

| Component | Retention | Configured In |
|-----------|-----------|---------------|
| Prometheus | 30 days | `PROMETHEUS_RETENTION_DAYS` env var |
| Loki | 7 days | `loki/loki.yml` |
| Backups | 30 days | `cleanup.sh` script |