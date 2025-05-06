#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-05-06
#FileName:          verify_cert_chain.sh
#URL:               http://github.com/lxwcd
#Description:       shell script
#Copyright (C):     2025 All rights reserved
#********************************************************************

# Usage:
# 1. Without intermediate CA:
#    ./verify_cert_chain.sh --root-ca rootCA.crt --cert server.crt
# 2. With intermediate CA:
#    ./verify_cert_chain.sh --root-ca rootCA.crt --intermediate-ca intermediateCA.crt --cert server.crt

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --root-ca)
            ROOT_CA_CERT_FILE="$2"
            shift 2
            ;;
        --intermediate-ca)
            INTERMEDIATE_CA_CERT_FILE="$2"
            shift 2
            ;;
        --cert)
            SERVER_CERT_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

# Check if required arguments are provided
if [ -z "$ROOT_CA_CERT_FILE" ] || [ -z "$SERVER_CERT_FILE" ]; then
    echo "Usage: $0 --root-ca <rootCA.crt> [--intermediate-ca <intermediateCA.crt>] --cert <server.crt>"
    exit 1
fi

# Build the certificate chain
if [ -n "$INTERMEDIATE_CA_CERT_FILE" ]; then
    # With intermediate CA
    openssl verify -CAfile "$ROOT_CA_CERT_FILE" -untrusted "$INTERMEDIATE_CA_CERT_FILE" "$SERVER_CERT_FILE"
else
    # Without intermediate CA
    openssl verify -CAfile "$ROOT_CA_CERT_FILE" "$SERVER_CERT_FILE"
fi
