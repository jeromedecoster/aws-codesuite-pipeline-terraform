#!/bin/bash

# the project root directory, parent directory of this script file
dir="$(cd "$(dirname "$0")"; pwd)"
cd "$dir"

# log $1 in underline green then $2 in yellow
log() {
    echo -e "\033[1;4;32m$1\033[0m \033[1;33m$2\033[0m"
}

PROJECT_NAME=$(terraform output | grep project_name | sed 's|.*= ||')

log download s3://$PROJECT_NAME/public/hello.out
aws s3 cp s3://$PROJECT_NAME/public/hello.out hello.out

log execute hello.out
chmod u+x ./hello.out
./hello.out