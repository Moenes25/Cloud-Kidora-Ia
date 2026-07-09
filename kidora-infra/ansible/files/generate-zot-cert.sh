#!/bin/bash
# Script to generate self-signed CA certificate for Zot Registry
# Certificate matches the specifications provided:
# - Common Name: localhost
# - Organization: Zot Registry
# - Country: US
# - RSA 2048-bit key
# - Valid for 1 year

set -e

CERT_DIR="."

# Create private key and self-signed certificate with IP SANs
openssl req -x509 -newkey rsa:2048 -keyout "${CERT_DIR}/key.pem" -out "${CERT_DIR}/cert.pem" -days 365 -nodes \
  -subj "/C=US/O=Zot Registry/CN=209.222.10.132" \
  -addext "basicConstraints=critical,CA:TRUE" \
  -addext "keyUsage=keyCertSign,cRLSign" \
  -addext "subjectKeyIdentifier=hash" \
  -addext "authorityKeyIdentifier=keyid:always" \
  -addext "subjectAltName=IP:209.222.10.132,DNS:localhost,IP:127.0.0.1"

# Set appropriate permissions
chmod 644 "${CERT_DIR}/cert.pem"
chmod 600 "${CERT_DIR}/key.pem"

echo "Certificate generated successfully!"
echo "Certificate: ${CERT_DIR}/cert.pem"
echo "Private Key: ${CERT_DIR}/key.pem"
