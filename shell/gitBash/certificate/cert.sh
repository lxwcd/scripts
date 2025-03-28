#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-03-26
#FileName:          cert.sh
#URL:               http://github.com/lxwcd
#Description:       shell script for git bash
#Copyright (C):     2025 All rights reserved
#********************************************************************

#!/bin/bash

. env.sh

# Client information
CLIENT_COMMON_NAME="revorked client" # need to be unique for each client
#CLIENT_COMMON_NAME="uaexpert" # need to be unique for each client
CLIENT_VALIDITY_DAYS=365
CLIENT_KEY_LENGTH=2048
#CLIENT_KEY_FILE="${ISSUED_DIR}/uaexpert_key"
#CLIENT_CSR_FILE="${ISSUED_DIR}/uaexpert_csr"
#CLIENT_CERT_FILE="${ISSUED_DIR}/uaexpert"
CLIENT_KEY_FILE="${ISSUED_DIR}/uaexpert_revorked_key"
CLIENT_CSR_FILE="${ISSUED_DIR}/uaexpert_revorked_csr"
CLIENT_CERT_FILE="${ISSUED_DIR}/uaexpert_revorked"
CLIENT_ALGORITHM="RSA"  # Algorithm type
CLIENT_PKEYOPT="rsa_keygen_bits:2048"  # Algorithm-specific options
CLIENT_IP="192.168.160.173"
CLIENT_APP_URI="urn:localhost:UnifiedAutomation:UaExpert"

# Examples of other algorithms that can be used (commented out, can be enabled as needed)
# CA_ALGORITHM="ECDSA"
# CA_PKEYOPT="ec_paramgen_curve:prime256v1"
# 
# CLIENT_ALGORITHM="ED25519"
# CLIENT_PKEYOPT=""

# Check if CA certificate and private key exist, if not, generate CA certificate
if [ ! -f "${CA_CERT_FILE}.crt" ] || [ ! -f "${CA_KEY_FILE}.key" ]; then
  . ca.sh
fi

# Generate client private key
openssl genpkey -algorithm ${CLIENT_ALGORITHM} -out ${CLIENT_KEY_FILE}.key -pkeyopt ${CLIENT_PKEYOPT}

# Generate CSR
openssl req -new -key ${CLIENT_KEY_FILE}.key -out ${CLIENT_CSR_FILE}.csr \
  -subj "//C=${COUNTRY}\ST=${STATE}\L=${CITY}\O=${ORG}\CN=${CLIENT_COMMON_NAME}"

#************************* use openssl x509 command ******************************************
# Issue client certificate (using temporary configuration file)
#cat > client_ext.cnf << EOF
#[usr_cert]
#basicConstraints = CA:FALSE
#keyUsage = digitalSignature,keyEncipherment
#extendedKeyUsage = clientAuth
#subjectAltName = IP:${CLIENT_IP},URI:${CLIENT_APP_URI}
#EOF

# openssl x509 -req -in ${CLIENT_CSR_FILE}.csr -CA ${CA_CERT_FILE}.crt -CAkey ${CA_KEY_FILE}.key \
#  -CAcreateserial -days ${CLIENT_VALIDITY_DAYS} -out ${CLIENT_CERT_FILE}.crt -extfile client_ext.cnf

#************************* use openssl ca command ******************************************
cat > client_ext.cnf << EOF
[v3_client]
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = clientAuth
subjectAltName = IP:${CLIENT_IP},URI:${CLIENT_APP_URI}
EOF

# Issue client certificate using openssl ca command with -batch option
openssl ca -batch -config "${OPENSSL_CNF_FILE}" -in ${CLIENT_CSR_FILE}.csr -out ${CLIENT_CERT_FILE}.crt \
  -days ${CLIENT_VALIDITY_DAYS} -cert ${CA_CERT_FILE}.crt -keyfile ${CA_KEY_FILE}.key \
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
  echo "01" > "${SERIAL_FILE}"
fi

# Clean up temporary files
rm client_ext.cnf

# Display client certificate information
#openssl x509 -in ${CLIENT_CERT_FILE}.crt -text -noout