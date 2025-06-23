#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-05-06
#FileName:          intermediate_level1_ca.sh
#URL:               http://github.com/lxwcd
#Description:       shell script
#Copyright (C):     2025 All rights reserved
#********************************************************************

. env.sh

# openssl_intermediate.cnf file
OPENSSL_INTERMEDIATE_CNF_FILE="${CERTIFICATES_DIR}/openssl_intermediate.cnf"

# Create openssl_intermediate.cnf if it doesn't exist
if [ ! -f "${OPENSSL_INTERMEDIATE_CNF_FILE}" ]; then
  cat > "${OPENSSL_INTERMEDIATE_CNF_FILE}" << EOF
[ ca ]
default_ca = CA_intermediate

[ CA_intermediate ]
dir = ${CERTIFICATES_DIR}
certs = ${ISSUED_DIR}
crl_dir = ${CRL_DIR}
database = ${INDEX_TXT_FILE}
new_certs_dir = ${ISSUED_DIR}
certificate = ${INTERMEDIATE_CA_LEVEL1_CERT_FILE}.crt
serial = ${SERIAL_FILE}
crl = ${CUR_CRL_FILE_PEM}
private_key = ${INTERMEDIATE_CA_LEVEL1_KEY_FILE}.key
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
x509_extensions = v3_ca_intermediate

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
commonName_default = MyFirstLevelIntermediateCA
emailAddress = Email Address
emailAddress_default = admin@example.com

[ req_attributes ]
challengePassword = A challenge password
challengePassword_min = 4
challengePassword_max = 20
unstructuredName = An optional company name

[ v3_ca_intermediate ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints = critical, CA:true, pathlen:0
# keyUsage = critical, digitalSignature, cRLSign, keyCertSign
subjectAltName = IP:${INTERMEDIATE_CA_IP},URI:${INTERMEDIATE_CA_APP_URI}

[v3_client]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints = CA:FALSE
keyUsage = digitalSignature,keyEncipherment
extendedKeyUsage = clientAuth
subjectAltName = IP:${CLIENT_IP},URI:${CLIENT_APP_URI} 

[ usr_cert ]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer

[ crl_ext ]
authorityKeyIdentifier=keyid:always
EOF
fi

# Check if CA certificate and private key exist, if not, generate CA certificate
if [ ! -f "${CA_CERT_FILE}.crt" ] || [ ! -f "${CA_KEY_FILE}.key" ]; then
  . ca.sh
fi

# Generate first-level intermediate CA private key
openssl genpkey -algorithm ${INTERMEDIATE_CA_LEVEL1_ALGORITHM} -out ${INTERMEDIATE_CA_LEVEL1_KEY_FILE}.key -pkeyopt ${INTERMEDIATE_CA_LEVEL1_PKEYOPT}

# Read the current serial number from the serial file
CURRENT_SERIAL=$(cat ${SERIAL_FILE})
echo "Current serial number: ${CURRENT_SERIAL}"

# Save the current serial number to serial.old
echo "${CURRENT_SERIAL}" > "${SERIAL_FILE}.old"

# Increment the serial number
NEW_SERIAL_NUM=$((CURRENT_SERIAL + 1))

# Format the new serial number to maintain leading zeros (e.g., 00000001 becomes 00000002)
NEW_SERIAL=$(printf "%08d" ${NEW_SERIAL_NUM})

# Update the serial file with the new serial number
echo "${NEW_SERIAL}" > "${SERIAL_FILE}"
echo "New serial number: ${NEW_SERIAL}"


# Generate first-level intermediate CA certificate signing request (CSR)
openssl req -new -key ${INTERMEDIATE_CA_LEVEL1_KEY_FILE}.key -out ${INTERMEDIATE_CA_LEVEL1_DIR}/intermediate_ca_level1.csr \
  -subj "//C=${COUNTRY}\ST=${STATE}\L=${CITY}\O=${ORG}\CN=${INTERMEDIATE_CA_LEVEL1_COMMON_NAME}"

# Create first-level intermediate CA certificate (signed by root CA)
openssl ca -batch -config "${OPENSSL_INTERMEDIATE_CNF_FILE}" -in ${INTERMEDIATE_CA_LEVEL1_DIR}/intermediate_ca_level1.csr -out ${INTERMEDIATE_CA_LEVEL1_CERT_FILE}.crt \
  -days ${INTERMEDIATE_CA_LEVEL1_VALIDITY_DAYS} -cert ${CA_CERT_FILE}.crt -keyfile ${CA_KEY_FILE}.key \
  -extensions v3_ca_intermediate

# Generate first-level intermediate CA PEM and DER files
openssl pkey -in ${INTERMEDIATE_CA_LEVEL1_KEY_FILE}.key -out ${INTERMEDIATE_CA_LEVEL1_KEY_FILE}.pem -inform pem -outform pem
openssl pkey -in ${INTERMEDIATE_CA_LEVEL1_KEY_FILE}.key -out ${INTERMEDIATE_CA_LEVEL1_KEY_FILE}.der -inform pem -outform der
openssl x509 -in ${INTERMEDIATE_CA_LEVEL1_CERT_FILE}.crt -out ${INTERMEDIATE_CA_LEVEL1_CERT_FILE}.pem -inform pem -outform pem
openssl x509 -in ${INTERMEDIATE_CA_LEVEL1_CERT_FILE}.crt -out ${INTERMEDIATE_CA_LEVEL1_CERT_FILE}.der -inform pem -outform der

# Display first-level intermediate CA certificate information
openssl x509 -in ${INTERMEDIATE_CA_LEVEL1_CERT_FILE}.crt -text -noout

# Clean up temporary files
# rm ${INTERMEDIATE_CA_LEVEL1_DIR}/intermediate_ca_level1.csr
