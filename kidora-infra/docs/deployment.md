# 📦 Deployment Guide

## First-Time Deployment

### 1. Prerequisites Check

```bash
# Verify tools
terraform --version  # >= 1.5
ansible --version    # >= 2.15
ssh-keygen -l -f ~/.ssh/id_rsa.pub  # SSH key exists

# Check environment
echo $HCLOUD_TOKEN  # Should be set or in terraform.tfvars
```

### 2. Infrastructure Provisioning

```bash
cd kidora-infra/terraform

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Set hcloud_token, domain, email

# Provision
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Note the output IP
SERVER_IP=$(terraform output -raw server_ipv4)
echo "Server IP: $SERVER_IP"
```

### 3. DNS Configuration

Create these A records at your DNS provider:
- `@` or `YOUR_DOMAIN` → `$SERVER_IP` (Frontend)
- `api.YOUR_DOMAIN` → `$SERVER_IP` (Backend)
- `traefik.YOUR_DOMAIN` → `$SERVER_IP` (Dashboard)
- `grafana.YOUR_DOMAIN` → `$SERVER_IP` (optional)
- `prometheus.YOUR_DOMAIN` → `$SERVER_IP` (optional)

### 4. Ansible Deployment

```bash
cd ../ansible

# Update inventory with server IP
sed -i "s/YOUR_SERVER_IP/$SERVER_IP/g" inventory/production.yml

# Bootstrap the server
ansible-playbook -i inventory/production.yml playbooks/bootstrap.yml

# Deploy the application
ansible-playbook -i inventory/production.yml playbooks/docker.yml

# Configure services
ansible-playbook -i inventory/production.yml playbooks/traefik.yml
ansible-playbook -i inventory/production.yml playbooks/postgres.yml
ansible-playbook -i inventory/production.yml playbooks/minio.yml

# Optional: Monitoring
ansible-playbook -i inventory/production.yml playbooks/monitoring.yml

# Configure backups
ansible-playbook -i inventory/production.yml playbooks/backup.yml
```

### 5. Verify Deployment

```bash
# Check services are running
ssh root@$SERVER_IP "docker ps"

# Check logs
ssh root@$SERVER_IP "docker-compose -f /opt/kidora/docker-compose.prod.yml logs --tail=100"

# Test endpoints
curl -I https://YOUR_DOMAIN
curl -I https://api.YOUR_DOMAIN/actuator/health
```

## Subsequent Deployments

### Update All Services
```bash
./scripts/update.sh
```

### Update Specific Service
```bash
./scripts/update.sh backend
./scripts/update.sh frontend
```

### Rollback
```bash
./scripts/rollback.sh backend v1.2.3
```

## Troubleshooting

### Server not reachable
- Check Hetzner Cloud Console: https://console.hetzner.cloud
- Verify firewall rules in Terraform
- Check the server hasn't been blocked (billing issue)

### SSL Certificate not issued
- Ensure DNS A record points to the server IP
- Wait up to 5 minutes for DNS propagation
- Check Traefik logs: `docker logs kidora-traefik`

### Database connection issues
```bash
# Check PostgreSQL is running
ssh root@$SERVER_IP "docker exec kidora-postgres pg_isready -U kidora"

# Check logs
ssh root@$SERVER_IP "docker logs kidora-postgres --tail 50"
```

### Docker Compose issues
```bash
# Check all services
ssh root@$SERVER_IP "cd /opt/kidora && docker-compose -f docker-compose.prod.yml ps"

# Restart everything
ssh root@$SERVER_IP "cd /opt/kidora && docker-compose -f docker-compose.prod.yml down && docker-compose -f docker-compose.prod.yml up -d"