#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-03-29
#FileName:          view_cert.sh
#URL:               http://github.com/lxwcd
#Description:       shell script
#Copyright (C):     2025 All rights reserved
#********************************************************************


# Check if the correct number of arguments is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <certificate_chain_file>"
    exit 1
fi

# Get the certificate chain file name
CERT_FILE="$1"

# Check if the certificate file exists
if [ ! -f "$CERT_FILE" ]; then
    echo "Error: Certificate chain file '$CERT_FILE' not found."
    exit 1
fi

# Use openssl to parse the certificate chain file
echo "Certificate Chain Details for: $CERT_FILE"
echo "----------------------------------"
openssl crl2pkcs7 -nocrl -certfile "$CERT_FILE" | openssl pkcs7 -print_certs -text -noout
