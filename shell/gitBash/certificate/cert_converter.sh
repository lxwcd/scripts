#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-05-06
#FileName:          cert_converter.sh
#URL:               http://github.com/lxwcd
#Description:       Shell script to convert between common certificate and private key file formats
#Copyright (C):     2025 All rights reserved
#********************************************************************

# Usage:
# ./cert_converter.sh -i input_file -o output_file -if input_format -of output_format
# ./cert_converter.sh -h

# Initialize variables
input_file=""
output_file=""
input_format=""
output_format=""
show_help="false"

# Function to display help message
show_help() {
    cat << EOF
Usage: $0 -i input_file -o output_file -if input_format -of output_format

Options:
    -i, --input          Input file
    -o, --output         Output file
    -if, --input-format  Input format (CRT, PEM, DER, KEY)
    -of, --output-format Output format (CRT, PEM, DER)
    -h, --help           Show this help message

Examples:
    # Convert CRT to PEM
    $0 -i input.crt -o output.pem -if CRT -of PEM

    # Convert CRT to DER
    $0 -i input.crt -o output.der -if CRT -of DER

    # Convert PEM to CRT
    $0 -i input.pem -o output.crt -if PEM -of CRT

    # Convert PEM to DER
    $0 -i input.pem -o output.der -if PEM -of DER

    # Convert DER to CRT
    $0 -i input.der -o output.crt -if DER -of CRT

    # Convert DER to PEM
    $0 -i input.der -o output.pem -if DER -of PEM

    # Convert KEY to PEM
    $0 -i input.key -o output.pem -if KEY -of PEM

    # Convert KEY to DER
    $0 -i input.key -o output.der -if KEY -of DER
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--input)
            input_file="$2"
            shift 2
            ;;
        -o|--output)
            output_file="$2"
            shift 2
            ;;
        -if|--input-format)
            input_format="$2"
            shift 2
            ;;
        -of|--output-format)
            output_format="$2"
            shift 2
            ;;
        -h|--help)
            show_help="true"
            shift
            ;;
        *)
            echo "Invalid option: $1" >&2
            show_help
            exit 1
            ;;
    esac
done

# Check if help is requested
if [ "$show_help" = "true" ]; then
    show_help
    exit 0
fi

# Check if all required arguments are provided
if [ -z "$input_file" ] || [ -z "$output_file" ] || [ -z "$input_format" ] || [ -z "$output_format" ]; then
    echo "Error: Missing required arguments."
    show_help
    exit 1
fi

# Function to convert certificate or private key
convert_file() {
    local input_format="$1"
    local output_format="$2"
    local input_file="$3"
    local output_file="$4"

    case $input_format in
        CRT|PEM)
            case $output_format in
                PEM|CRT)
                    openssl x509 -in "$input_file" -out "$output_file" -outform pem
                    ;;
                DER)
                    openssl x509 -in "$input_file" -out "$output_file" -outform der
                    ;;
                *)
                    echo "Error: Unsupported output format for CRT/PEM input."
                    exit 1
                    ;;
            esac
            ;;
        DER)
            case $output_format in
                CRT|PEM)
                    openssl x509 -in "$input_file" -inform der -out "$output_file" -outform pem
                    ;;
                *)
                    echo "Error: Unsupported output format for DER input."
                    exit 1
                    ;;
            esac
            ;;
        KEY)
            case $output_format in
                PEM)
                    openssl pkey -in "$input_file" -out "$output_file"
                    ;;
                DER)
                    openssl pkey -in "$input_file" -out "$output_file" -outform der
                    ;;
                *)
                    echo "Error: Unsupported output format for KEY input."
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo "Error: Unsupported input format."
            exit 1
            ;;
    esac
}

# Perform the conversion
convert_file "$input_format" "$output_format" "$input_file" "$output_file"

echo "Conversion completed successfully."
