# 🚀 Kidora Infrastructure

Infrastructure as Code (IaC) for deploying the Kidora application on a **single Hetzner Cloud** server using Terraform + Ansible + Docker Compose.

## 📋 Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                 Hetzner CX22/CX32               │
│                  (Ubuntu 24.04)                  │
│                                                  │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌─────────────┐ │
│  │Traefik│  │ PG   │  │MinIO │  │Monitor Stack│ │
│  │(Proxy)│  │(DB)  │  │(Obj.)│  │(Pro/Graf/..)│ │
│  └──┬───┘  └──────┘  └──────┘  └─────────────┘ │
│     │                                            │
│  ┌──▼───────────────────────┐                    │
│  │  Backend (Spring Boot)   │                    │
│  │  Frontend (React/Vue)    │                    │
│  └──────────────────────────┘                    │
│                                                  │
│  ┌─────────────────┐  ┌────────────────────┐    │
│  │  /mnt/data      │  │  /mnt/backup       │    │
│  │  (Hetzner Vol.) │  │  (Hetzner Vol.)    │    │
│  └─────────────────┘  └────────────────────┘    │
└─────────────────────────────────────────────────┘
```

## 🛠️ Prerequisites

- [Hetzner Cloud](https://console.hetzner.cloud) account + API token
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html) >= 2.15
- SSH key pair (`~/.ssh/id_rsa.pub`)
- A **domain name** pointing to the server IP (for SSL certificates)

## 🚦 Quick Start

### 1. Configure Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Hetzner API token and settings
vim terraform.tfvars
```

### 2. Provision the Server

```bash
cd ..
# Option A: Use the deploy script
./scripts/deploy.sh

# Option B: Step by step
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 3. Get the Server IP

```bash
terraform output server_ipv4
# Update the Ansible inventory with this IP
cd ..
sed -i "s/YOUR_SERVER_IP/$(terraform -chdir=terraform output -raw server_ipv4)/g" ansible/inventory/production.yml
```

### 4. Configure DNS

Point your domain's **A record** to the server IP:
- `kidora.example.com` → Server IP → Frontend
- `api.kidora.example.com` → Server IP → Backend API

### 5. Deploy with Ansible

```bash
cd ansible
ansible-playbook -i inventory/production.yml playbooks/bootstrap.yml
ansible-playbook -i inventory/production.yml playbooks/docker.yml
ansible-playbook -i inventory/production.yml playbooks/traefik.yml
ansible-playbook -i inventory/production.yml playbooks/postgres.yml
ansible-playbook -i inventory/production.yml playbooks/minio.yml
ansible-playbook -i inventory/production.yml playbooks/monitoring.yml  # optional
ansible-playbook -i inventory/production.yml playbooks/backup.yml
```

## 📁 Project Structure

```
kidora-infra/
├── terraform/          # Hetzner provisioning
│   ├── main.tf         # Locals & common config
│   ├── providers.tf    # Hetzner provider
│   ├── variables.tf    # Input variables
│   ├── server.tf       # Server resource
│   ├── network.tf      # Private network
│   ├── firewall.tf     # Security rules
│   ├── volumes.tf      # Data & backup volumes
│   └── outputs.tf      # Output values
├── ansible/
│   ├── inventory/      # Production & staging hosts
│   └── playbooks/      # Deployment playbooks
├── docker/
│   ├── docker-compose.yml      # Staging
│   ├── docker-compose.prod.yml # Production
│   ├── traefik/         # Reverse proxy config
│   ├── postgres/        # DB init scripts
│   └── minio/           # Object storage config
├── monitoring/          # Prometheus/Grafana/Loki
├── scripts/             # Deploy, backup, restore
└── docs/                # Documentation
```

## 🔄 Maintenance

| Task | Command |
|------|---------|
| Update services | `./scripts/update.sh` |
| Rollback backend | `./scripts/rollback.sh backend v1.2.3` |
| Backup database | `./scripts/backup.sh postgres` |
| Restore database | `./scripts/restore.sh postgres /mnt/backup/postgres/file.sql.gz` |
| SSH to server | `ssh root@$(terraform -chdir=terraform output -raw server_ipv4)` |
| View logs | `ssh root@SERVER_IP "docker-compose -f /opt/kidora/docker-compose.prod.yml logs -f"` |

## 🔒 Security Notes

1. **Restrict SSH access**: Set `ssh_allowed_ips` to your specific IP in `terraform.tfvars`
2. **Change all passwords**: Update `.env` values via Ansible vault
3. **Use Ansible Vault** for secrets:
   ```bash
   ansible-vault create ansible/inventory/vault.yml
   ansible-playbook -i inventory/production.yml --ask-vault-pass playbooks/docker.yml
   ```
4. **Enable auto-backups** (already enabled in Terraform)
5. **Keep the system updated**: `apt update && apt upgrade`

## 📊 Monitoring

- Grafana: `https://grafana.YOUR_DOMAIN` (user: admin)
- Prometheus: `https://prometheus.YOUR_DOMAIN`
- Traefik Dashboard: `https://traefik.YOUR_DOMAIN`

## 🐳 Docker Images

The application uses pre-built Docker images:
- **Backend:** `ghcr.io/moenes25/client-kidora-backend:latest`
- **Frontend:** `ghcr.io/moenes25/client-kidora-frontend:latest`

To build and push new versions:

```bash
cd ../backend
docker build -t ghcr.io/moenes25/client-kidora-backend:v1.2.3 .
docker push ghcr.io/moenes25/client-kidora-backend:v1.2.3

cd ../frontend
docker build -t ghcr.io/moenes25/client-kidora-frontend:v1.2.3 .
docker push ghcr.io/moenes25/client-kidora-frontend:v1.2.3