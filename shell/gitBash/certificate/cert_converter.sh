#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-05-06
#FileName:          cert_converter.sh
#URL:               http://github.com/lxwcd
#Description:       shell script
#Copyright (C):     2025 All rights reserved
#********************************************************************

#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-05-06
#FileName:          cert_converter.sh
#URL:               http://github.com/lxwcd
#Description:       Shell script to convert between common certificate file formats
#Copyright (C):     2025 All rights reserved
#********************************************************************

# Usage:
# ./cert_converter.sh -i input_file -o output_file -if input_format -of output_format
# ./cert_converter.sh -h

# Parse command line arguments
while getopts ":i:o:if:of:h" opt; do
    case $opt in
        i) input_file="$OPTARG" ;;
        o) output_file="$OPTARG" ;;
        if) input_format="$OPTARG" ;;
        of) output_format="$OPTARG" ;;
        h) show_help="true" ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
    esac
done

# Function to display help message
show_help() {
    cat << EOF
Usage: $0 -i input_file -o output_file -if input_format -of output_format

Options:
    -i, --input          Input file
    -o, --output         Output file
    -if, --input-format  Input format (CRT, PEM, DER)
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
EOF
}

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

# Convert certificate
case $input_format in
    CRT)
        case $output_format in
            PEM)
                openssl x509 -inform pem -in "$input_file" -outform pem -out "$output_file"
                ;;
            DER)
                openssl x509 -inform pem -in "$input_file" -outform der -out "$output_file"
                ;;
            *)
                echo "Error: Unsupported output format."
                exit 1
                ;;
        esac
        ;;
    PEM)
        case $output_format in
            CRT)
                openssl x509 -inform pem -in "$input_file" -outform pem -out "$output_file"
                ;;
            DER)
                openssl x509 -inform pem -in "$input_file" -outform der -out "$output_file"
                ;;
            *)
                echo "Error: Unsupported output format."
                exit 1
                ;;
        esac
        ;;
    DER)
        case $output_format in
            CRT)
                openssl x509 -inform der -in "$input_file" -outform pem -out "$output_file"
                ;;
            PEM)
                openssl x509 -inform der -in "$input_file" -outform pem -out "$output_file"
                ;;
            *)
                echo "Error: Unsupported output format."
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Error: Unsupported input format."
        exit 1
        ;;
esac

echo "Conversion completed successfully."