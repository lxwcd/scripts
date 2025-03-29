#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-03-29
#FileName:          parse_asn1.sh
#URL:               http://github.com/lxwcd
#Description:       shell script
#Copyright (C):     2025 All rights reserved
#********************************************************************


# Check if the correct number of arguments is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <certificate_file>"
    exit 1
fi

# Get the certificate file name
CERT_FILE="$1"

# Check if the certificate file exists
if [ ! -f "$CERT_FILE" ]; then
    echo "Error: Certificate file '$CERT_FILE' not found."
    exit 1
fi

# Determine the format of the certificate file
# Default to PEM format
FORMAT="PEM"

# Check if the file has a .der extension
if [[ "$CERT_FILE" == *.der ]]; then
    FORMAT="DER"
fi

# Use openssl asn1parse to display the ASN.1 structure of the certificate
echo "ASN.1 Structure of Certificate: $CERT_FILE (Format: $FORMAT)"
echo "------------------------------------------------------------"

if [ "$FORMAT" == "DER" ]; then
    openssl asn1parse -inform DER -in "$CERT_FILE" -i
else
    openssl asn1parse -in "$CERT_FILE" -i
fi
