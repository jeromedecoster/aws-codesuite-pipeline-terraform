#!/bin/bash

# the project root directory, parent directory of this script file
dir="$(cd "$(dirname "$0")"; pwd)"
cd "$dir"

# log $1 in underline green then $2 in yellow
log() {
    echo -e "\033[1;4;32m$1\033[0m \033[1;33m$2\033[0m"
}

if [[ ! -f ssh_rsa.pub ]]
then
    PASS=$(mktemp --dry-run XXXXX | tr '[A-Z]' '[a-z]')
    log create 'passphrase.txt'
    echo -n "$PASS" > passphrase.txt
    log create 'ssh_rsa + ssh_rsa.pub keys'
    ssh-keygen -q -t rsa -N $PASS -f ssh_rsa
fi

terraform init