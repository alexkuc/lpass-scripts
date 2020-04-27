#!/bin/bash
##
## Usage: lpass-att-export.sh
##
##

trap cleanup 0

cleanup () {
  unset LPASS_DISABLE_PINENTRY
  unset MASTER_PASSWORD
}

usage() { echo "Usage: $0 [-l <email>] [-o <outdir>] [-i <id>]" 1>&2; exit 1; }

while getopts ":i:o:hl:" o; do
    case "${o}" in
        i)
            id=${OPTARG}
            ;;
        o)
            outdir=${OPTARG}
            ;;
        l)
            email=${OPTARG}
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

echo -n Password:
read -rs MASTER_PASSWORD
printf "\n\n"

export LPASS_DISABLE_PINENTRY=1

if [[ -z "$MASTER_PASSWORD" ]]; then
    echo "Failed to supply master password!"
    exit 1
fi

if [ ! -d "$outdir" ]; then mkdir -p "$outdir"; fi

if ! lpass status; then
  if [ -z "${email}" ]; then
    echo "No login data found, Please login with -l or use lpass login before."
    exit 1;
  fi
  lpass login "${email}"
fi

if [ -z "${id}" ]; then
  ids=$(lpass ls | sed -E 's/.*id:[[:space:]]([0-9]+)]/\1/')
else
  ids=${id}
fi

for id in ${ids}; do
  show=$(lpass show "${id}" <<<"$MASTER_PASSWORD")
  attcount=$(echo "${show}" | grep -c "att-")
  path=$(lpass show --format="%/as%/ag%an" "${id}" <<<"$MASTER_PASSWORD" | uniq | tail -1)

  until [  "${attcount}" -lt 1 ]; do
    att=$(lpass show "${id}" <<<"$MASTER_PASSWORD" | grep att- | sed "${attcount}q;d")
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

    lpass show --attach="${attid}" "${id}" --quiet > "${out}" <<<"$MASTER_PASSWORD"

    ((attcount-=1))
  done
done

