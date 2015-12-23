#!/bin/bash
set -euo pipefail

device="${1-}"
mount="${PWD}/root"

[ -z "${device}" ] && ( echo "Usage: $0 DEVICE"; exit 1 ) 

cleanup() {
  sudo umount ${mount}/dev
  sudo umount ${mount}/proc
  sudo umount ${mount}/sys
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

[ ! -d "${mount}" ] && mkdir "${mount}"

bootdev=$(ls "${device}"*1)
rootdev=$(ls "${device}"*2)

sudo mount "${rootdev}" "${mount}"
[ ! -d "${mount}/boot" ] && mkdir "${mount}/boot"
sudo mount "${bootdev}" "${mount}/boot"
sudo mount -t proc none ${mount}/proc
sudo mount -t sysfs none ${mount}/sys
sudo mount -o bind /dev ${mount}/dev

sudo cp /usr/bin/qemu-arm-static ${mount}/usr/bin/
#echo ':arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:' > /proc/sys/fs/binfmt_misc/register

sudo rm -f ${mount}/etc/resolv.conf
sudo cp /etc/resolv.conf ${mount}/etc/resolv.conf
[ -f $HOME/.ssh/id_rsa.pub ] && sudo cp $HOME/.ssh/id_rsa.pub ${mount}/root/.ssh/authorized_keys

sudo chroot ${mount} /bin/bash <<EOS

echo kibar > /etc/hostname

pacman -Syu --noconfirm wpa_supplicant wpa_actiond ifplugd crda dialog avahi nss-mdns vim bash-completion

sed -i '/^hosts: /s/files dns/files mdns dns/' /etc/nsswitch.conf

ln -sf /usr/lib/systemd/system/serial-getty@.service /etc/systemd/system/getty.target.wants/serial-getty@ttyAMA0.service
ln -sf /usr/lib/systemd/system/netctl-auto@.service /etc/systemd/system/multi-user.target.wants/netctl-auto@wlan0.service
ln -sf /usr/lib/systemd/system/netctl-ifplugd@.service /etc/systemd/system/multi-user.target.wants/netctl-ifplugd@eth0.service
ln -sf /usr/lib/systemd/system/avahi-daemon.service /etc/systemd/system/multi-user.target.wants/avahi-daemon.service

cat <<EOD > /etc/netctl/wlan0-Home
Description=''
Interface=wlan0
Connection=wireless
Security=wpa
ESSID=DrayTek
IP=dhcp
Key=just\ for\ now
EOD
EOS
