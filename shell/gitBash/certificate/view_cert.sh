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
    echo "Usage: $0 <certificate_file>"
    exit 1
fi

# Get the certificate chain file name
CERT_FILE="$1"

# Check if the certificate file exists
if [ ! -f "$CERT_FILE" ]; then
    echo "Error: Certificate file '$CERT_FILE' not found."
    exit 1
fi

# Check the file format and parse accordingly
echo "Certificate Details for: $CERT_FILE"
echo "----------------------------------"

FILE_EXTENSION="${CERT_FILE##*.}"

case "$FILE_EXTENSION" in
    pem|crt)
        # For PEM or CRT formatted certificate
        echo "Parsing as PEM/CRT Certificate..."
        openssl x509 -in "$CERT_FILE" -text -noout
        ;;
    der)
        # For DER formatted certificate
        echo "Parsing as DER Certificate..."
        openssl x509 -inform der -in "$CERT_FILE" -text -noout
        ;;
    csr)
        # For Certificate Signing Request
        echo "Parsing as Certificate Signing Request..."
        openssl req -in "$CERT_FILE" -text -noout
        ;;
    key)
        # For Private Key in PEM format (default)
        echo "Parsing as Private Key (PEM)..."
        openssl rsa -in "$CERT_FILE" -text -noout
        ;;
    crl)
        # For Certificate Revocation List
        echo "Parsing as Certificate Revocation List..."
        openssl crl -in "$CERT_FILE" -text -noout
        ;;
    *)
        echo "Error: Unsupported file format '$FILE_EXTENSION'."
        echo "Supported formats: .crt, .pem, .der, .csr, .key, .crl"
        exit 1
        ;;
esac
