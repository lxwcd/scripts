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

#!/bin/bash

. env.sh

# Examples of other algorithms that can be used (commented out, can be enabled as needed)
# CA_ALGORITHM="ECDSA"
# CA_PKEYOPT="ec_paramgen_curve:prime256v1"
# 
# CLIENT_ALGORITHM="ED25519"
# CLIENT_PKEYOPT=""

# Generate CA private key
openssl genpkey -algorithm ${CA_ALGORITHM} -out ${CA_KEY_FILE}.key -pkeyopt ${CA_PKEYOPT}

# Generate CA certificate
openssl req -x509 -new -key ${CA_KEY_FILE}.key -days ${CA_VALIDITY_DAYS} -out ${CA_CERT_FILE}.crt \
  -subj "//C=${COUNTRY}\ST=${STATE}\L=${CITY}\O=${ORG}\CN=${CA_COMMON_NAME}" \
  -addext "basicConstraints = critical,CA:TRUE" \
  -addext "keyUsage = critical,keyCertSign,cRLSign" \
  -addext "subjectAltName = IP:${CA_IP},URI:${CA_APP_URI}"

# Generate CA PEM and DER files
openssl pkey -in ${CA_KEY_FILE}.key -out ${CA_KEY_FILE}.pem -inform pem -outform pem
openssl pkey -in ${CA_KEY_FILE}.key -out ${CA_KEY_FILE}.der -inform pem -outform der
openssl x509 -in ${CA_CERT_FILE}.crt -out ${CA_CERT_FILE}.pem -inform pem -outform pem
openssl x509 -in ${CA_CERT_FILE}.crt -out ${CA_CERT_FILE}.der -inform pem -outform der