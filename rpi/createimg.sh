#!/bin/bash
set -euo pipefail

cleanup() {
  echo "cleaning up"
  [ -d root/boot ] && sudo umount root/boot
  [ -d root ] && ( sudo umount root && rmdir root )
  [ -n "${loop-}" ] && sudo losetup -d ${loop}
}
trap cleanup EXIT

error() {
  local parent_lineno="$1"
  local code="${3:-1}"
  echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  exit "${code}"
}
trap 'error ${LINENO}' ERR


image=kibar-$(date +%F).img

[ ! -f "ArchLinuxARM-rpi-latest.tar.gz" ] && wget "http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz"

[ -f root.img ] && rm ${image}
fallocate -l 900M ${image}

parted --script ${image} mklabel msdos
parted --script ${image} mkpart primary fat32 0% 100M
parted --script ${image} mkpart primary ext4 100M 100%

loop=$(sudo losetup --show -Pf ${image})

ls ${loop}*
echo $loop

exit 0

mkfs.vfat -F32 boot.img
mkfs.ext4 root.img

[ ! -d root ] && mkdir root

sudo mount root.img root
sudo mkdir root/boot 
sudo mount boot.img root/boot

