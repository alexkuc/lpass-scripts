#!/bin/bash

trap cleanup 0

cleanup () {
    if [[ -n "$LOGGED_IN" ]]; then lpass logout --force; fi
    unset PASSWORD LPASS_DISABLE_PINENTRY LOGGED_IN
    echo ""
}

LOGGED_IN=''

if [[ -z "$1" ]]; then echo "Failed to supply entry name or id!" && exit 1; fi

echo -n Username:
read -r USERNAME
echo -n Password:
read -rs PASSWORD
printf "\n\n"

if [[ -z "$USERNAME" ]]; then echo "Failed to supply username!" && exit 1; fi
if [[ -z "$PASSWORD" ]];then echo "Failed to supply password!" && exit 1; fi

export LPASS_DISABLE_PINENTRY=1

echo -e "\033[0;32mLog in\033[0m: starting."

LOGGED_IN=$(lpass login "$USERNAME" <<<"$PASSWORD")

SHOW_ENTRY="$(lpass show "$1" <<<"$PASSWORD")"

if [[ ! "$SHOW_ENTRY" ]]; then
    echo "Failed to authenticate entry $1!"
    exit 1
else
    echo "$SHOW_ENTRY"
fi
