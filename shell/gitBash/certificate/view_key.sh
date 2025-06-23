#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-03-29
#FileName:          view_key.sh
#URL:               http://github.com/lxwcd
#Description:       shell script
#Copyright (C):     2025 All rights reserved
#********************************************************************

# Check if the correct number of arguments is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <key_file>"
    exit 1
fi

# Get the key file name
CERT_FILE="$1"

# Check if the key file exists
if [ ! -f "$CERT_FILE" ]; then
    echo "Error: key file '$CERT_FILE' not found."
    exit 1
fi

# Check the file format and parse accordingly
echo "key Details for: $CERT_FILE"
echo "----------------------------------"

FILE_EXTENSION="${CERT_FILE##*.}"

case "$FILE_EXTENSION" in
    key)
    # For PEM formatted Private Key (default)
    echo "Parsing as PEM Private Key..."
    openssl rsa -in "$CERT_FILE" -text -noout
    ;;
    pem)
        # For PEM formatted Private Key
        echo "Parsing as PEM Private Key..."
        openssl rsa -in "$CERT_FILE" -text -noout
        ;;
    der)
        # For DER formatted Private Key
        echo "Parsing as DER Private Key..."
        openssl rsa -inform der -in "$CERT_FILE" -text -noout
        ;;

    *)
        echo "Error: Unsupported file format '$FILE_EXTENSION'."
        ;;
esac
