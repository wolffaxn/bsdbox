#!/usr/bin/env sh
#
# ZFS root install script
#
# Copyright (c) 2014-2015 Alexander Wolff <wolffaxn[at]gmail[dot]com>

set -e
# set -x

BOOTSIZE=512k
DEFAULT_POOLNAME=zroot
DEFAULT_ZFSROOTSIZE=64GB
DEFAULT_SWAPSIZE=2GB

usage() {
  echo "Usage: $0 -d device [-h] [-p pool_name] [-r zfs_root_size] [-s swap_size] [-l l2arc_size] [-z zil_size]"
}

while getopts d:h:p:r:s:l:z: o; do
  case "$o" in
    d)
      DEVICE="${OPTARG}"
      ;;
    h)
      usage;
      exit 1
      ;;
    p)
      POOL="${OPTARG}"
      ;;
    r)
      ZFSROOTSIZE="${OPTARG}"
      ;;
    s)
      SWAPSIZE="${OPTARG}"
      ;;
    l)
      L2ARCSIZE="${OPTARG}"
      ;;
    z)
      ZILSIZE="${OPTARG}"
      ;;
    [?])
      usage;
      exit 1
      ;;
  esac
done

if [ -z "$DEVICE" ]; then
  usage
  exit 1
fi

if [ -z "$POOL" ]; then
  POOL=${DEFAULT_POOLNAME}
fi

if [ -z "$ZFSROOTSIZE" ]; then
  ZFSROOTSIZE=${DEFAULT_ZFSROOTSIZE}
fi

if [ -z "$SWAPSIZE" ]; then
  SWAPSIZE=${DEFAULT_SWAPSIZE}
fi

#
# Disk Partitioning Root
#

# delete a GUID partition table on boot disk (the SSD)
gpart destroy -F ${DEVICE} 2> /dev/null

# create a GUID partition table on boot disk (the SSD)
gpart create -s gpt ${DEVICE}

# create necessary partitions on root disk and add ZFS aware boot code

# add the boot partition
gpart add -t freebsd-boot -a 4k -s ${BOOTSIZE} ${DEVICE}
# add the swap partition
gpart add -t freebsd-swap -a 4k -l swap -s ${SWAPSIZE} ${DEVICE}
# add the ZFS partition
gpart add -t freebsd-zfs -a 4k -l system -s ${ZFSROOTSIZE} ${DEVICE}

# create ZIL and L2ARC partitions
if [ -n "${ZILSIZE}" -a -n "${L2ARCSIZE}" ]; then
  gpart add -t freebsd-zfs -a 4k -l log -s ${ZILSIZE} ${DEVICE}
  gpart add -t freebsd-zfs -a 4k -l cache -s ${L2ARCSIZE} ${DEVICE}
fi

# write boot loader to the disk
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ${DEVICE}

# create virtual device which define 4K sector size
gnop create -S 4096 /dev/gpt/system

# load ZFS module
kldload zfs

# create ZFS Pool
zpool create -f -m none -o altroot=/mnt -O canmount=off ${POOL} /dev/gpt/system.nop

# create filesystem
zfs set checksum=fletcher4 ${POOL}
zfs set atime=off ${POOL}
zfs set dedup=off ${POOL}

zfs create -o mountpoint=none ${POOL}/ROOT
zfs create -o mountpoint=/ ${POOL}/ROOT/default
zfs create -o mountpoint=/tmp -o compression=lz4 -o setuid=off ${POOL}/tmp
chmod 1777 /mnt/tmp

zfs create -o mountpoint=/usr ${POOL}/usr
zfs create ${POOL}/usr/local

zfs create -o mountpoint=/home -o setuid=off ${POOL}/home

zfs create -o compression=lz4 -o setuid=off ${POOL}/usr/ports
zfs create -o compression=off -o exec=off -o setuid=off ${POOL}/usr/ports/distfiles
zfs create -o compression=off -o exec=off -o setuid=off ${POOL}/usr/ports/packages

zfs create -o compression=lz4 -o exec=off -o setuid=off ${POOL}/usr/src
zfs create ${POOL}/usr/obj

zfs create -o mountpoint=/var ${POOL}/var
zfs create -o compression=lz4 -o exec=off -o setuid=off ${POOL}/var/crash
zfs create -o exec=off -o setuid=off ${POOL}/var/db
zfs create -o compression=lz4 -o exec=on -o setuid=off ${POOL}/var/db/pkg
zfs create -o exec=off -o setuid=off ${POOL}/var/empty
zfs create -o compression=lz4 -o exec=off -o setuid=off ${POOL}/var/log
zfs create -o compression=gzip -o exec=off -o setuid=off ${POOL}/var/mail
zfs create -o exec=off -o setuid=off ${POOL}/var/run
zfs create -o compression=lz4 -o exec=on -o setuid=off ${POOL}/var/tmp
chmod 1777 /mnt/var/tmp

zpool set bootfs=${POOL}/ROOT/default ${POOL}

cat << EOF > /tmp/bsdinstall_boot/loader.conf
# /boot/loader.conf

# load zfs
zfs_load="YES"
vfs.root.mountfrom="zfs:zroot/ROOT/default"

# file system labels
geom_label_load="YES"
# use gpt ids instead of gptids or disks idents
kern.geom.label.disk_ident.enable="0"
kern.geom.label.gpt.enable=1
kern.geom.label.gptid.enable=0
EOF

cat << EOF > /tmp/bsdinstall_etc/fstab
#/etc/fstab

# Device          Mountpoint    FStype    Options   Dump  Pass#
/dev/gpt/swap     none          swap      sw        0     0
EOF

cat << EOF > /tmp/bsdinstall_etc/rc.conf
# /etc/rc.conf

# clear /tmp
clear_tmp_enable="YES"

# disable dumpdev
dumpdev="NO"

# enable SSH Daemon
sshd_enable="YES"

# disable sendmail
sendmail_enable="NO"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"

# syslog shouldn't listen for incoming connections
syslogd_flags="-ss"

# disable RPC Binder Daemon
rpcbind_enable="NO"

# ZFS support
zfs_enable="YES"

# power savings
powerd_enable="YES"
EOF

exit
