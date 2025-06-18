#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-03-28
#FileName:          self_signed_cert.sh
#URL:               http://github.com/lxwcd
#Description:       shell script for git bash
#Copyright (C):     2025 All rights reserved
#********************************************************************

. env.sh

# Self-signed client information
SELF_SIGNED_CLIENT_COMMON_NAME="self_signed_client"  # need to be unique for each client
SELF_SIGNED_CLIENT_VALIDITY_DAYS=365
SELF_SIGNED_CLIENT_KEY_LENGTH=2048
SELF_SIGNED_CLIENT_KEY_FILE="${ISSUED_DIR}/self_signed_client_key"
SELF_SIGNED_CLIENT_CERT_FILE="${ISSUED_DIR}/self_signed_client"
SELF_SIGNED_CLIENT_ALGORITHM="RSA"  # Algorithm type
SELF_SIGNED_CLIENT_PKEYOPT="rsa_keygen_bits:2048"  # Algorithm-specific options
SELF_SIGNED_CLIENT_IP="192.168.160.200"
SELF_SIGNED_CLIENT_APP_URI="urn:localhost:self_signed_client"

# Define serial number for self-signed certificate
SELF_SIGNED_SERIAL_FILE="${CERTIFICATES_DIR}/self_signed_serial"
if [ ! -f "${SELF_SIGNED_SERIAL_FILE}" ]; then
    echo "00000001" > "${SELF_SIGNED_SERIAL_FILE}"
fi
CURRENT_SERIAL=$(cat "${SELF_SIGNED_SERIAL_FILE}")
NEW_SERIAL_NUM=$((CURRENT_SERIAL + 1))
NEW_SERIAL=$(printf "%08d" ${NEW_SERIAL_NUM})
echo "${NEW_SERIAL}" > "${SELF_SIGNED_SERIAL_FILE}"

# Generate self-signed client private key
openssl genpkey -algorithm ${SELF_SIGNED_CLIENT_ALGORITHM} -out ${SELF_SIGNED_CLIENT_KEY_FILE}.key -pkeyopt ${SELF_SIGNED_CLIENT_PKEYOPT}

# Generate self-signed client certificate with extensions and specified serial number
openssl req -x509 -new -key ${SELF_SIGNED_CLIENT_KEY_FILE}.key -days ${SELF_SIGNED_CLIENT_VALIDITY_DAYS} -out ${SELF_SIGNED_CLIENT_CERT_FILE}.crt \
  -subj "//C=${COUNTRY}\ST=${STATE}\L=${CITY}\O=${ORG}\CN=${SELF_SIGNED_CLIENT_COMMON_NAME}" \
  -addext "basicConstraints = critical,CA:FALSE" \
  -addext "keyUsage = digitalSignature,keyEncipherment" \
  -addext "extendedKeyUsage = clientAuth" \
  -addext "subjectAltName = IP:${SELF_SIGNED_CLIENT_IP},URI:${SELF_SIGNED_CLIENT_APP_URI}" \
  -set_serial ${CURRENT_SERIAL}

# Generate self-signed client PEM and DER files
openssl pkey -in ${SELF_SIGNED_CLIENT_KEY_FILE}.key -out ${SELF_SIGNED_CLIENT_KEY_FILE}.pem -inform pem -outform pem
openssl pkey -in ${SELF_SIGNED_CLIENT_KEY_FILE}.key -out ${SELF_SIGNED_CLIENT_KEY_FILE}.der -inform pem -outform der
openssl x509 -in ${SELF_SIGNED_CLIENT_CERT_FILE}.crt -out ${SELF_SIGNED_CLIENT_CERT_FILE}.pem -inform pem -outform pem
openssl x509 -in ${SELF_SIGNED_CLIENT_CERT_FILE}.crt -out ${SELF_SIGNED_CLIENT_CERT_FILE}.der -inform pem -outform der

# Display self-signed client certificate information
openssl x509 -in ${SELF_SIGNED_CLIENT_CERT_FILE}.crt -text -noout
