#!/bin/bash
set -euo pipefail

device="${1-}"
mount="${PWD}/root"

[ -z "${device}" ] && ( echo "Usage: $0 DEVICE"; exit 1 ) 

error() {
  local parent_lineno="$1"
  local code="${3:-1}"
  echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  exit "${code}"
}
trap 'error ${LINENO}' ERR

[ ! -d "${mount}" ] && mkdir "${mount}"

bootdev=$(ls "${device}"*1)
rootdev=$(ls "${device}"*2)

sudo mount "${rootdev}" "${mount}"
[ ! -d "${mount}/boot" ] && mkdir "${mount}/boot"
sudo mount "${bootdev}" "${mount}/boot"


