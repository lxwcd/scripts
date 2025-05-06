#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-05-06
#FileName:          cert_by_inter_level1_ca.sh
#URL:               http://github.com/lxwcd
#Description:       shell script
#Copyright (C):     2025 All rights reserved
#********************************************************************

. env.sh

# Client information
CLIENT_COMMON_NAME="cert_level2" # need to be unique for each client
CLIENT_VALIDITY_DAYS=365
CLIENT_KEY_LENGTH=2048
CLIENT_KEY_FILE="${ISSUED_DIR}/cert_level2_key"
CLIENT_CSR_FILE="${ISSUED_DIR}/cert_level2"
CLIENT_CERT_FILE="${ISSUED_DIR}/cert_level2"
CLIENT_ALGORITHM="RSA"  # Algorithm type
CLIENT_PKEYOPT="rsa_keygen_bits:2048"  # Algorithm-specific options
CLIENT_IP="192.168.160.173"
CLIENT_APP_URI="urn:localhost:UnifiedAutomation:UaExpert"

# Check if first-level intermediate CA certificate and private key exist, if not, generate first-level intermediate CA certificate
if [ ! -f "${INTERMEDIATE_CA_LEVEL1_CERT_FILE}.crt" ] || [ ! -f "${INTERMEDIATE_CA_LEVEL1_KEY_FILE}.key" ]; then
  . intermediate_level1_ca.sh
fi

# Generate client private key
openssl genpkey -algorithm ${CLIENT_ALGORITHM} -out ${CLIENT_KEY_FILE}.key -pkeyopt ${CLIENT_PKEYOPT}

# Generate CSR
openssl req -new -key ${CLIENT_KEY_FILE}.key -out ${CLIENT_CSR_FILE}.csr \
  -subj "//C=${COUNTRY}\ST=${STATE}\L=${CITY}\O=${ORG}\CN=${CLIENT_COMMON_NAME}"

# Create temporary configuration file for client certificate extensions
cat > client_ext.cnf << EOF
[v3_client]
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = clientAuth
subjectAltName = IP:${CLIENT_IP},URI:${CLIENT_APP_URI}
EOF

# Issue client certificate using first-level intermediate CA
openssl ca -batch -config "${OPENSSL_INTERMEDIATE_CNF_FILE}" -in ${CLIENT_CSR_FILE}.csr -out ${CLIENT_CERT_FILE}.crt \
  -days ${CLIENT_VALIDITY_DAYS} -cert ${INTERMEDIATE_CA_LEVEL1_CERT_FILE}.crt -keyfile ${INTERMEDIATE_CA_LEVEL1_KEY_FILE}.key \
  -extfile client_ext.cnf -extensions v3_client

# Generate client PEM and DER files
openssl pkey -in ${CLIENT_KEY_FILE}.key -out ${CLIENT_KEY_FILE}.pem -inform pem -outform pem
openssl pkey -in ${CLIENT_KEY_FILE}.key -out ${CLIENT_KEY_FILE}.der -inform pem -outform der
openssl x509 -in ${CLIENT_CERT_FILE}.crt -out ${CLIENT_CERT_FILE}.pem -inform pem -outform pem
openssl x509 -in ${CLIENT_CERT_FILE}.crt -out ${CLIENT_CERT_FILE}.der -inform pem -outform der

# Initialize CA database files if they don't exist
if [ ! -f "${INDEX_TXT_FILE}" ]; then
  touch "${INDEX_TXT_FILE}"
fi
if [ ! -f "${SERIAL_FILE}" ]; then
  echo "00000001" > "${SERIAL_FILE}"
fi

# Clean up temporary files
rm client_ext.cnf

# Display client certificate information
# openssl x509 -in ${CLIENT_CERT_FILE}.crt -text -noout
