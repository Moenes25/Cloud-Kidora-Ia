# 💾 Backup & Restore Guide

## Automated Backups

The Ansible `backup.yml` playbook configures these cron jobs:

| Schedule | Backup | Destination |
|----------|--------|-------------|
| Daily at 2:00 AM | PostgreSQL dump | `/mnt/backup/postgres/` |
| Weekly (Sunday 3AM) | Uploaded files | `/mnt/backup/uploads/` |
| Monthly (1st 4AM) | Cleanup old backups | (removes > 30 days) |

## Manual Backups

### Database
```bash
# SSH to server
ssh root@YOUR_SERVER_IP

# Direct pg_dump
docker exec kidora-postgres pg_dump -U kidora kidora | gzip > /mnt/backup/postgres/manual_$(date +%Y%m%d).sql.gz

# Or use the script
/opt/kidora/scripts/backup.sh postgres
```

### Uploads
```bash
# Tar the uploads directory
/opt/kidora/scripts/backup.sh uploads

# Or manually
tar -czf /mnt/backup/uploads/manual_$(date +%Y%m%d).tar.gz -C /mnt/data uploads
```

### Configuration
```bash
/opt/kidora/scripts/backup.sh configs
```

### Full Backup
```bash
# Everything (PG + uploads + configs)
/opt/kidora/scripts/backup.sh full
```

## Restore

### Database Restore
```bash
# List available backups
ls -lh /mnt/backup/postgres/

# Restore
/opt/kidora/scripts/restore.sh postgres /mnt/backup/postgres/kidora_pg_20250101_020000.sql.gz

# Manual restore
gunzip -c /mnt/backup/postgres/kidora_pg_20250101_020000.sql.gz | \
  docker exec -i kidora-postgres psql -U kidora -d kidora
```

### Uploads Restore
```bash
/opt/kidora/scripts/restore.sh uploads /mnt/backup/uploads/kidora_uploads_20250101_020000.tar.gz
```

## Hetzner Automated Backups

Terraform enables Hetzner's built-in weekly backups:
- Automatic weekly image snapshots
- Stored in Hetzner infrastructure
- Can restore entire server from backup
- Configured via `backups = true` in `server.tf`

## Backup Storage

```
/mnt/backup/
├── postgres/
│   ├── kidora_pg_20250101_020000.sql.gz
│   ├── kidora_pg_20250102_020000.sql.gz
│   └── latest.sql.gz → kidora_pg_20250102_020000.sql.gz
├── uploads/
│   ├── kidora_uploads_20250101_020000.tar.gz
│   └── latest.tar.gz → kidora_uploads_20250101_020000.tar.gz
└── configs/
    └── kidora_configs_20250101_020000.tar.gz
```

## Disaster Recovery Plan

1. **Provision new server** via Terraform
2. **Install Docker** (bootstrap playbook)
3. **Mount volumes** with restored data
4. **Deploy Docker Compose** stack
5. **Restore database** from latest backup
6. **Restore uploads** from latest backup
7. **Verify** application functionality

## Security

- Backup volumes are separate from data volumes
- Database credentials stored in Ansible vault (encrypted)
- Backups are not encrypted at rest by default
- ⚠️ For sensitive data, enable encryption:
  ```bash
  # Encrypt backup before storing off-server
  gpg --symmetric --cipher-algo AES256 backup.sql.gz