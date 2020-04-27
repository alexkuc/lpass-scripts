#!/bin/bash
##
## Usage: lpass-att-export.sh
##
##

trap cleanup 0

cleanup () {
  if [[ -n "$LOGGED_IN" ]]; then lpass logout --force; fi
  unset PASSWORD LPASS_DISABLE_PINENTRY LOGGED_IN
  echo ""
}

LOGGED_IN=''

usage() { echo "Usage: $0 [-o <outdir>] [-i <id>]" 1>&2; exit 1; }

while getopts ":i:o:hl:" o; do
    case "${o}" in
        i)
            id=${OPTARG}
            ;;
        o)
            outdir=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${outdir}" ]; then
    usage
fi

command -v lpass >/dev/null 2>&1 || { echo >&2 "I require lpass but it's not installed.  Aborting."; exit 1; }

echo -n "Username: "
read -r USERNAME
echo -n "Password: "
read -rs PASSWORD
printf "\n\n"

export LPASS_DISABLE_PINENTRY=1

if [[ -z "$USERNAME" ]]; then echo "Failed to supply username!" && exit 1; fi

if [[ -z "$PASSWORD" ]]; then echo "Failed to supply password!" && exit 1; fi

if [ ! -d "$outdir" ]; then mkdir -p "$outdir"; fi

echo -e "\033[0;32mLog in\033[0m: starting."
LOGGED_IN=$(lpass login "$USERNAME" <<<"$PASSWORD")

if [ -z "${id}" ]; then
  ids=$(lpass ls | sed -E 's/.*id:[[:space:]]([0-9]+)]/\1/')
else
  ids=${id}
fi

for id in ${ids}; do
  show=$(lpass show "${id}" <<<"$PASSWORD")
  attcount=$(echo "${show}" | grep -c "att-")
  path=$(lpass show --format="%/as%/ag%an" "${id}" <<<"$PASSWORD" | uniq | tail -1)

  until [  "${attcount}" -lt 1 ]; do
    att=$(lpass show "${id}" <<<"$PASSWORD" | grep att- | sed "${attcount}q;d")
    attid=$(echo "$att" | cut -d ':' -f 1)
    attname=$(echo "$att" | cut -d ':' -f 2)

    if [[ -z  ${attname}  ]]; then
      attname=${path#*/}
    fi

    path=${path//\\//}
    mkdir -p "${outdir}/${path}"
    out=${outdir}/${path}/${attname}

    if [[ -f ${out} ]]; then
        out=${outdir}/${path}/${attcount}_${attname}
    fi

    echo "${id}" - "${path}" ": " "${attid}" "-" "${attname}" " > " "${out}"

    lpass show --attach="${attid}" "${id}" --quiet > "${out}" <<<"$PASSWORD"

    ((attcount-=1))
  done
done

