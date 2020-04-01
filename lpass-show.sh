#!/bin/bash

trap cleanup 0

cleanup () {
    unset LPASS_DISABLE_PINENTRY
    unset MASTER_PASSWORD
}

echo -n Password:
read -rs MASTER_PASSWORD
printf "\n\n"

if [[ -z "$MASTER_PASSWORD" ]]; then
    echo "Failed to supply master password!"
    exit 1
fi

if [[ -z "$1" ]]; then
    echo "Failed to supply entry id!"
    exit 1
fi

export LPASS_DISABLE_PINENTRY=1

cmd="$(lpass show "$1" <<<"$MASTER_PASSWORD")"

if [[ ! "$cmd" ]]; then
    echo "Failed to authenticate entry $1!"
    exit 1
else
    echo "$cmd"
fi
