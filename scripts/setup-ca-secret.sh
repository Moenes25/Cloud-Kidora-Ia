#!/bin/bash
# Script to help set up the MY_CA_CERT GitHub secret

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if we're in a GitHub repository
if ! gh repo view &> /dev/null; then
    echo "Error: Not in a GitHub repository or not authenticated"
    echo "Run 'gh auth login' first"
    exit 1
fi

# Read the certificate
CERT_FILE="kidora-infra/ansible/files/cert.pem"

if [ ! -f "$CERT_FILE" ]; then
    echo "Error: Certificate file not found at $CERT_FILE"
    exit 1
fi

# Set the secret
echo "Setting up MY_CA_CERT secret for current repository..."
gh secret set MY_CA_CERT < "$CERT_FILE"

echo "Secret MY_CA_CERT has been set successfully!"
echo "You can now use this secret in your GitHub Actions workflows."