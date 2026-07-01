#!/bin/bash
# ═══════════════════════════════════════════════════════
# Kidora — Deploy Script
# ═══════════════════════════════════════════════════════
# Runs Terraform + Ansible to provision and deploy.
# Usage:
#   ./deploy.sh                    # Full deploy
#   ./deploy.sh --skip-terraform   # Skip Terraform (if server already exists)
#   ./deploy.sh --skip-ansible     # Skip Ansible (just provision)
# ═══════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

SKIP_TERRAFORM=false
SKIP_ANSIBLE=false

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --skip-terraform) SKIP_TERRAFORM=true ;;
    --skip-ansible) SKIP_ANSIBLE=true ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

# ════ Step 1: Terraform ────────────────────────
run_terraform() {
  log "═══ Running Terraform ═══"
  cd "${PROJECT_DIR}/terraform"

  if [ ! -f "terraform.tfvars" ]; then
    log "Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    log "⚠️  Please edit terraform/terraform.tfvars with your Hetzner API token!"
    exit 1
  fi

  terraform init
  terraform plan -out=tfplan
  terraform apply tfplan

  # Get server IP
  SERVER_IP=$(terraform output -raw server_ipv4)
  log "Server IP: $SERVER_IP"

  # Update Ansible inventory
  cd "$PROJECT_DIR"
  sed -i "s/YOUR_SERVER_IP/$SERVER_IP/g" ansible/inventory/production.yml

  log "═══ Terraform Complete ═══"
}

# ════ Step 2: Ansible ──────────────────────────
run_ansible() {
  log "═══ Running Ansible ═══"

  cd "${PROJECT_DIR}/ansible"

  # Bootstrap server
  log "Running bootstrap playbook..."
  ansible-playbook -i inventory/production.yml playbooks/bootstrap.yml

  # Deploy Docker stack
  log "Deploying Docker stack..."
  ansible-playbook -i inventory/production.yml playbooks/docker.yml

  # Configure services
  log "Configuring Traefik..."
  ansible-playbook -i inventory/production.yml playbooks/traefik.yml

  log "Configuring PostgreSQL..."
  ansible-playbook -i inventory/production.yml playbooks/postgres.yml

  log "Configuring MinIO..."
  ansible-playbook -i inventory/production.yml playbooks/minio.yml

  # Monitoring (optional)
  log "Deploying monitoring stack..."
  ansible-playbook -i inventory/production.yml playbooks/monitoring.yml || true

  # Backups
  log "Configuring backups..."
  ansible-playbook -i inventory/production.yml playbooks/backup.yml

  log "═══ Ansible Complete ═══"
}

# ════ Main ─────────────────────────────────────
main() {
  log "═══ Kidora Deploy Script ═══"

  if [ "$SKIP_TERRAFORM" = false ]; then
    run_terraform
  else
    log "⏩ Skipping Terraform (--skip-terraform)"
  fi

  if [ "$SKIP_ANSIBLE" = false ]; then
    run_ansible
  else
    log "⏩ Skipping Ansible (--skip-ansible)"
  fi

  log "═══ Deploy Complete ═══"
  log ""
  log "Your application is being deployed!"
  log "Access it at: https://${DOMAIN_NAME:-your-domain.com}"
}

main "$@"