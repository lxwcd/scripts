#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-03-27
#FileName:          env.sh
#URL:               http://github.com/lxwcd
#Description:       shell script for git bash
#Copyright (C):     2025 All rights reserved
#********************************************************************

# Define directories
CERTIFICATES_DIR="certs"
CA_DIR="${CERTIFICATES_DIR}/ca_server"
#CA_DIR="${CERTIFICATES_DIR}/ca_client"
ISSUED_DIR="${CERTIFICATES_DIR}/issued"
CRL_DIR="${CERTIFICATES_DIR}/crl"

# Create directories if they don't exist
mkdir -p \
 "${CERTIFICATES_DIR}" \
 "${CA_DIR}" \
 "${ISSUED_DIR}" \
 "${CRL_DIR}"

# Define variables
# Define common variables for CA and certificates
#[ policy_match ]
#countryName		= match
#stateOrProvinceName	= match
#organizationName	= match
#organizationalUnitName	= optional
#commonName		= supplied
#emailAddress		= optional
COUNTRY="CN"
STATE="Liaoning"
CITY="Dalian"
ORG="cd"

# CA information
#CA_COMMON_NAME="CA Server"
CA_COMMON_NAME="CA Client"
CA_VALIDITY_DAYS=3650
CA_KEY_LENGTH=2048
CA_KEY_FILE="${CA_DIR}/ca_server_key"
#CA_KEY_FILE="${CA_DIR}/ca_client_key"
CA_CERT_FILE="${CA_DIR}/ca_server"
#CA_CERT_FILE="${CA_DIR}/ca_client"
CA_ALGORITHM="RSA"  # Algorithm type
CA_PKEYOPT="rsa_keygen_bits:2048"  # Algorithm-specific options
CA_IP="192.168.160.102"
CA_APP_URI="urn:open62541.server.application"
#CA_APP_URI="urn:localhost:UnifiedAutomation:UaExpert"

# CRL file
CUR_CRL_FILE_PEM="${CRL_DIR}/crl.pem"
CUR_CRL_FILE_DER="${CRL_DIR}/crl.der"

# openssl.cnf file
OPENSSL_CNF_FILE="${CERTIFICATES_DIR}/openssl.cnf"

# index file
INDEX_TXT_FILE="${CERTIFICATES_DIR}/index.txt"
SERIAL_FILE="${CERTIFICATES_DIR}/serial"

# Initialize CA database files if they don't exist
if [ ! -f "${INDEX_TXT_FILE}" ]; then
  touch "${INDEX_TXT_FILE}"
fi
if [ ! -f "${SERIAL_FILE}" ]; then
  echo "00000001" > "${SERIAL_FILE}"
fi

# Create openssl.cnf if it doesn't exist
if [ ! -f "${OPENSSL_CNF_FILE}" ]; then
  cat > "${OPENSSL_CNF_FILE}" << EOF
[ ca ]
default_ca = CA_default

[ CA_default ]
dir = ${CERTIFICATES_DIR}
certs = ${ISSUED_DIR}
crl_dir = ${CRL_DIR}
database = ${INDEX_TXT_FILE}
new_certs_dir = ${ISSUED_DIR}
certificate = ${CA_CERT_FILE}.crt
serial = ${SERIAL_FILE}
crl = ${CUR_CRL_FILE_PEM}
private_key = ${CA_KEY_FILE}.key
default_days = 365
default_crl_days = 30
default_md = sha256
preserve = no
email_in_dn = no
name_opt = ca_default
cert_opt = ca_default
policy = policy_match

[ policy_match ]
countryName = match
stateOrProvinceName = match
localityName = match
organizationName = match
organizationalUnitName = optional
commonName = supplied
emailAddress = optional

[ req ]
default_bits = 2048
default_md = sha256
default_keyfile = privkey.pem
distinguished_name = req_distinguished_name
attributes = req_attributes
x509_extensions = v3_ca

[ req_distinguished_name ]
countryName = Country Name (2 letter code)
countryName_default = CN
stateOrProvinceName = State or Province Name (full name)
stateOrProvinceName_default = Liaoning
localityName = Locality Name (e.g., city)
localityName_default = Dalian
0.organizationName = Organization Name (e.g., company)
0.organizationName_default = cd
organizationalUnitName = Organizational Unit Name (e.g., section)
commonName = Common Name (e.g., your name or your server's hostname)
commonName_default = MyRootCA
emailAddress = Email Address
emailAddress_default = admin@example.com

[ req_attributes ]
challengePassword = A challenge password
challengePassword_min = 4
challengePassword_max = 20
unstructuredName = An optional company name

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
subjectAltName = IP:${CA_IP},URI:${CA_APP_URI} 

[v3_client]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:FALSE
keyUsage = digitalSignature,keyEncipherment
extendedKeyUsage = clientAuth
subjectAltName = IP:${CLIENT_IP},URI:${CLIENT_APP_URI} 
EOF
fi
