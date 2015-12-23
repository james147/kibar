#!/bin/bash
set -euo pipefail

device="${1-}"
mount="${PWD}/root"

[ -z "${device}" ] && ( echo "Usage: $0 DEVICE"; exit 1 ) 

cleanup() {
  [ ! -d ${mount}/boot ] || sudo umount ${mount}/boot
  [ ! -d ${mount} ] || ( sudo umount ${mount} && rmdir ${mount} )
}
trap cleanup EXIT

error() {
  local parent_lineno="$1"
  local code="${3:-1}"
  echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  exit "${code}"
}
trap 'error ${LINENO}' ERR

[ ! -f "ArchLinuxARM-rpi-latest.tar.gz" ] && wget "http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz"

sudo parted --script ${device} mklabel msdos
sudo parted --script ${device} mkpart primary fat32 0% 100M
sudo parted --script ${device} mkpart primary ext4 100M 100%

bootdev=$(ls "${device}"*1)
rootdev=$(ls "${device}"*2)

sudo mkfs.vfat -F32 "${bootdev}" >/dev/null
sudo mkfs.ext4 -F "${rootdev}" >/dev/null

[ ! -d "${mount}" ] && mkdir "${mount}"

sudo mount "${rootdev}" "${mount}"
sudo mkdir -p "${mount}/boot"
sudo mount "${bootdev}" "${mount}/boot"

sudo bsdtar -xpf ArchLinuxARM-rpi-latest.tar.gz -C ${mount}
sudo sync ${device}
