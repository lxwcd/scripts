#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-03-27
#FileName:          ca.sh
#URL:               http://github.com/lxwcd
#Description:       shell script for git bash
#Copyright (C):     2025 All rights reserved
#********************************************************************

. env.sh

# Examples of other algorithms that can be used (commented out, can be enabled as needed)
# CA_ALGORITHM="ECDSA"
# CA_PKEYOPT="ec_paramgen_curve:prime256v1"
# 
# CLIENT_ALGORITHM="ED25519"
# CLIENT_PKEYOPT=""

# Generate CA private key
openssl genpkey -algorithm ${CA_ALGORITHM} -out ${CA_KEY_FILE}.key -pkeyopt ${CA_PKEYOPT}

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

# Generate CA certificate
#openssl req -x509 -new -key ${CA_KEY_FILE}.key -days ${CA_VALIDITY_DAYS} -out ${CA_CERT_FILE}.crt \
#  -subj "//C=${COUNTRY}\ST=${STATE}\L=${CITY}\O=${ORG}\CN=${CA_COMMON_NAME}" \
#  -addext "basicConstraints = critical,CA:TRUE" \
#  -addext "keyUsage = critical,keyCertSign,cRLSign" \
#  -addext "subjectAltName = DNS:${CA_DNS},IP:${CA_IP},URI:${CA_APP_URI}" \
#  -set_serial ${CURRENT_SERIAL}

openssl req -x509 -new -key ${CA_KEY_FILE}.key -days ${CA_VALIDITY_DAYS} -out ${CA_CERT_FILE}.crt \
  -subj "//C=${COUNTRY}\ST=${STATE}\L=${CITY}\O=${ORG}\CN=${CA_COMMON_NAME}" \
  -addext "basicConstraints = CA:TRUE" \
  -set_serial ${CURRENT_SERIAL}

# Generate CA PEM and DER files
openssl pkey -in ${CA_KEY_FILE}.key -out ${CA_KEY_FILE}.pem -inform pem -outform pem
openssl pkey -in ${CA_KEY_FILE}.key -out ${CA_KEY_FILE}.der -inform pem -outform der
openssl x509 -in ${CA_CERT_FILE}.crt -out ${CA_CERT_FILE}.pem -inform pem -outform pem
openssl x509 -in ${CA_CERT_FILE}.crt -out ${CA_CERT_FILE}.der -inform pem -outform der

# Display ca certificate information
openssl x509 -in ${CA_CERT_FILE}.crt -text -noout
