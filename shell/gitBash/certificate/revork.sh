#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-03-27
#FileName:          revork.sh
#URL:               http://github.com/lxwcd
#Description:       shell script for git bash
#Copyright (C):     2025 All rights reserved
#********************************************************************

. env.sh

# Client information
REVORKED_CLIENT_CERT_FILE="${ISSUED_DIR}/uaexpert_revorked"

# CRL file
CRL_FILE_PEM="${CRL_DIR}/crl.pem"
CRL_FILE_DER="${CRL_DIR}/crl.der"

# Revoke certificate
openssl ca -config "${OPENSSL_CNF_FILE}" -revoke "${REVORKED_CLIENT_CERT_FILE}.crt"

# Generate CRL
openssl ca -config "${OPENSSL_CNF_FILE}" -gencrl -out "${CRL_FILE_PEM}"

# Convert CRL to DER format
openssl crl -in "${CRL_FILE_PEM}" -out "${CRL_FILE_DER}" -inform pem -outform der

# Display CRL information
openssl crl -in "${CRL_FILE_PEM}" -text -noout