#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-06-23
#FileName:          view_cert_chain.sh
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

# Check if the certificate chain file exists
if [ ! -f "$CERT_FILE" ]; then
    echo "Error: Certificate chain file '$CERT_FILE' not found."
    exit 1
fi

# Check the file format and parse accordingly
echo "Certificate Chain Details for: $CERT_FILE"
echo "----------------------------------"

FILE_EXTENSION="${CERT_FILE##*.}"

case "$FILE_EXTENSION" in
    pem|crt)
        # For PEM or CRT formatted certificate chain
        echo "Parsing as PEM/CRT Certificate Chain..."
        openssl crl2pkcs7 -nocrl -certfile "$CERT_FILE" | openssl pkcs7 -print_certs -text -noout
        ;;
    der)
        # For DER formatted certificate chain
        echo "Parsing as DER Certificate Chain..."
        openssl crl2pkcs7 -nocrl -inform der -certfile "$CERT_FILE" | openssl pkcs7 -print_certs -text -noout
        ;;
    *)
        echo "Error: Unsupported file format '$FILE_EXTENSION'."
        echo "Supported formats: .crt, .pem, .der"
        ;;
esac
