#!/bin/bash
#
#********************************************************************
#Author:            lx
#Date:              2025-03-29
#FileName:          push.sh
#URL:               http://github.com/lxwcd
#Description:       shell script
#Copyright (C):     2025 All rights reserved
#********************************************************************


#!/bin/bash

# Set maximum number of retries to avoid infinite loops
max_retries=10
# Set interval (in seconds) between retries
retry_interval=5

# Loop until the maximum number of retries is reached
for ((i=1; i<=max_retries; i++)); do
    echo "Attempt $i to push..."
    git push --force
    # Check if the previous command (git push) was successful
    if [ $? -eq 0 ]; then
        echo "Push succeeded!"
        exit 0  # Exit the script successfully
    else
        echo "Push failed. Retrying in $retry_interval seconds..."
        sleep $retry_interval  # Wait before retrying
    fi
done

# If all retries fail, exit with an error
echo "Maximum retries reached. Push failed!"
exit 1
