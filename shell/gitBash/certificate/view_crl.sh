#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-03-29
#FileName:          view_crl.sh
#URL:               http://github.com/lxwcd
#Description:       shell script
#Copyright (C):     2025 All rights reserved
#********************************************************************

# Check if the correct number of arguments is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <crl_file>"
    exit 1
fi

# Get the crl file name
CERT_FILE="$1"

# Check if the crl file exists
if [ ! -f "$CERT_FILE" ]; then
    echo "Error: crl file '$CERT_FILE' not found."
    exit 1
fi

# Check the file format and parse accordingly
echo "crl Details for: $CERT_FILE"
echo "----------------------------------"

FILE_EXTENSION="${CERT_FILE##*.}"

case "$FILE_EXTENSION" in
    crl)
        # For Certificate Revocation List
        echo "Parsing as Certificate Revocation List..."
        openssl crl -in "$CERT_FILE" -text -noout
        ;;
    pem)
        # For PEM formatted CRL
        echo "Parsing as PEM CRL..."
        openssl crl -in "$CERT_FILE" -text -noout
        ;;
    der)
        # For DER formatted CRL
        echo "Parsing as DER CRL..."
        openssl crl -inform der -in "$CERT_FILE" -text -noout
        ;;
    *)
        echo "Error: Unsupported file format '$FILE_EXTENSION'."
        ;;
esac
