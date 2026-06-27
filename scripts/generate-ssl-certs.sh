#!/bin/bash
# ============================================
# RASHA Super App — Generate Self-Signed SSL Certs
# ============================================
# Usage:
#   ./scripts/generate-ssl-certs.sh
#
# This generates self-signed certificates for local HTTPS development.
# The certificates are valid for 365 days and cover:
#   - rasha.local
#   - *.rasha.local
#   - localhost
#   - 127.0.0.1
# ============================================
set -e

CERT_DIR="./certs"
DAYS=3650
SUBJECT="/C=ID/ST=Jakarta/L=Jakarta/O=RASHA/OU=Development/CN=rasha.local"

echo ">> Generating self-signed SSL certificates..."

mkdir -p "$CERT_DIR"

# Generate CA key and certificate
openssl genrsa -out "$CERT_DIR/rasha-ca.key" 2048 2>/dev/null
openssl req -x509 -new -nodes -key "$CERT_DIR/rasha-ca.key" \
    -sha256 -days $DAYS \
    -out "$CERT_DIR/rasha-ca.crt" \
    -subj "$SUBJECT" 2>/dev/null

# Generate server key
openssl genrsa -out "$CERT_DIR/rasha.key" 2048 2>/dev/null

# Generate CSR with SAN
cat > "$CERT_DIR/san.cnf" << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C = ID
ST = Jakarta
L = Jakarta
O = RASHA
OU = Development
CN = rasha.local

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = rasha.local
DNS.2 = *.rasha.local
DNS.3 = localhost
DNS.4 = crm.rasha.local
DNS.5 = dynform.rasha.local
DNS.6 = erp.rasha.local
DNS.7 = api.rasha.local
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

openssl req -new -key "$CERT_DIR/rasha.key" \
    -out "$CERT_DIR/rasha.csr" \
    -config "$CERT_DIR/san.cnf" 2>/dev/null

# Sign the certificate
cat > "$CERT_DIR/v3_ext.cnf" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = rasha.local
DNS.2 = *.rasha.local
DNS.3 = localhost
DNS.4 = crm.rasha.local
DNS.5 = dynform.rasha.local
DNS.6 = erp.rasha.local
DNS.7 = api.rasha.local
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

openssl x509 -req -in "$CERT_DIR/rasha.csr" \
    -CA "$CERT_DIR/rasha-ca.crt" \
    -CAkey "$CERT_DIR/rasha-ca.key" \
    -CAcreateserial \
    -out "$CERT_DIR/rasha.crt" \
    -days $DAYS \
    -sha256 \
    -extfile "$CERT_DIR/v3_ext.cnf" 2>/dev/null

# Clean up temporary files
rm -f "$CERT_DIR/rasha.csr" "$CERT_DIR/san.cnf" "$CERT_DIR/v3_ext.cnf" "$CERT_DIR/rasha-ca.srl"

echo ">> SSL certificates generated in $CERT_DIR/"
echo "   - rasha.key   (server private key)"
echo "   - rasha.crt   (server certificate)"
echo "   - rasha-ca.crt (CA certificate)"
echo ""
echo ">> Install the CA certificate in your browser:"
echo "   Windows: Double-click rasha-ca.crt → Install Certificate → Local Machine → Trusted Root Certification Authorities"
echo "   macOS:   sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $CERT_DIR/rasha-ca.crt"
echo "   Linux:   sudo cp $CERT_DIR/rasha-ca.crt /usr/local/share/ca-certificates/rasha-ca.crt && sudo update-ca-certificates"
