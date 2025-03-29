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

# Get the certificate file name
CERT_FILE="$1"

# Check if the certificate file exists
if [ ! -f "$CERT_FILE" ]; then
    echo "Error: Certificate file '$CERT_FILE' not found."
    exit 1
fi

# Use openssl to display certificate details
echo "Certificate Details for: $CERT_FILE"
echo "----------------------------------"
openssl x509 -in "$CERT_FILE" -text -noout
