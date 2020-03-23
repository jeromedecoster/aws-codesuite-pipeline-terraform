#!/bin/bash

# the project root directory, parent directory of this script file
dir="$(cd "$(dirname "$0")"; pwd)"
cd "$dir"

# log $1 in underline green then $2 in yellow
log() {
    echo -e "\033[1;4;32m$1\033[0m \033[1;33m$2\033[0m"
}

# echo $1 in underline magenta then $2 in cyan
err() {
    echo -e "\033[1;4;35m$1\033[0m \033[1;36m$2\033[0m" >&2
}


OUTPUT=$(terraform output)
PUBLIC_KEY=$(echo "$OUTPUT" | grep ssh_public_key_id | sed 's|.*= ||')
URL_SSH=$(echo "$OUTPUT" | grep clone_url_ssh | sed 's|.*= ||')

CLONE_URL=$(echo "$URL_SSH" | sed "s|ssh://|ssh://$PUBLIC_KEY@|")
DIRECTORY=${URL_SSH##*/}

if [[ -d $DIRECTORY ]]
then
    err abort "the directory $DIRECTORY already exists"
    exit
fi

# echo ":$PUBLIC_KEY:"
# echo ":$URL_SSH:"
# echo ":$CLONE_URL:"
# echo ":$DIRECTORY:"

log 'ssh passphrase' $(cat passphrase.txt)

log git 'clone codecommit repository' 
GIT_SSH_COMMAND='ssh -i ./ssh_rsa' git clone $CLONE_URL

