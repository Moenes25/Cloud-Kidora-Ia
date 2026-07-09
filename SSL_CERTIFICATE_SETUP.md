# SSL Certificate Setup for GitHub Actions

This document explains how to configure SSL certificate trust for GitHub Actions runners to work with the self-signed certificate used by the Zot registry.

## Overview

The infrastructure uses a self-signed certificate for the Zot registry at `209.222.10.132:5000`. To allow GitHub Actions runners to trust this certificate, you have two options:

## Option 1: Install Certificate in Trust Store (Recommended)

This is the secure approach that properly validates the certificate.

### Step 1: Add Certificate to GitHub Secrets

Run the setup script to add your certificate to GitHub secrets:

```bash
# Make the script executable
chmod +x scripts/setup-ca-secret.sh

# Run the setup script (requires GitHub CLI)
./scripts/setup-ca-secret.sh
```

Or manually add the secret via GitHub CLI:

```bash
gh secret set MY_CA_CERT < kidora-infra/ansible/files/cert.pem
```

Or via GitHub web interface:
1. Go to your repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `MY_CA_CERT`
4. Value: Paste the entire contents of `kidora-infra/ansible/files/cert.pem`

### Step 2: Use the Certificate Trust Workflow

The workflow `.github/workflows/deploy.yml` will automatically:
1. Extract the certificate from the secret
2. Install it in the system trust store (`/usr/local/share/ca-certificates/`)
3. Run `update-ca-certificates` to trust the certificate

## Option 2: SSL Verification Bypass

If you need to bypass SSL verification (not recommended for production), use the alternative workflow:

`.github/workflows/deploy-ssl-bypass.yml`

This workflow:
1. Disables SSL verification for Git and curl
2. Uses the `insecure-registries` configuration in Docker daemon

## Files Created/Modified

### New Files
- `.github/workflows/deploy.yml` - Main deployment workflow with certificate trust
- `.github/workflows/deploy-ssl-bypass.yml` - Alternative workflow with SSL bypass
- `scripts/setup-ca-secret.sh` - Helper script to set up GitHub secret

### Modified Files
- `kidora-infra/ansible/playbooks/minio_db_zot.yml` - Added certificate installation task
- `kidora-infra/ansible/playbooks/docker.yml` - Added certificate installation and updated Docker config

## Certificate Details

The self-signed certificate is configured for:
- **Common Name**: `209.222.10.132`
- **Subject Alternative Names**: 
  - `IP:209.222.10.132`
  - `DNS:localhost`
  - `IP:127.0.0.1`
- **Organization**: Zot Registry
- **Country**: US
- **Valid for**: 365 days

## Testing Certificate Trust

After deployment, you can verify the certificate is trusted by running:

```bash
# On the target host
curl -v https://209.222.10.132:5000/v2/
```

If the certificate is properly trusted, you should see a successful response without SSL errors.