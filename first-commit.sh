#!/bin/bash

# the project root directory, parent directory of this script file
dir="$(cd "$(dirname "$0")"; pwd)"
cd "$dir"

# log $1 in underline green then $2 in yellow
log() {
    echo -e "\033[1;4;32m$1\033[0m \033[1;33m$2\033[0m"
}


URL_SSH=$(terraform output | grep clone_url_ssh | sed 's|.*= ||')
DIRECTORY=${URL_SSH##*/}


log 'ssh passphrase' $(cat passphrase.txt)

log git 'add files and commit'
cd $DIRECTORY
cp ../code/* .
git add .
git commit -m first-commit

log git 'push to codecommit repository'
GIT_SSH_COMMAND='ssh -i ../ssh_rsa' git push