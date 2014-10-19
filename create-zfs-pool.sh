#!/usr/bin/env sh
#
# ZFS pool install script
#
# Copyright (c) 2014 Alexander Wolff <wolffaxn[at]gmail[dot]com>

set -e
# set -x

DEFAULT_POOLNAME=zstore

usage() {
  echo "Usage: $0 -d devices [-h] [-p pool_name]"
}

while getopts d:h:p: o; do
  case "$o" in
    d)
      DEVICES="$DEVICES ${OPTARG}"
      ;;
    h)
      usage;
      exit 1
      ;;
    p)
      POOL="${OPTARG}"
      ;;
    [?])
      usage;
      exit 1
      ;;
  esac
done

if [ -z "$DEVICES" ]; then
  usage
  exit 1
fi

if [ -z "$POOL" ]; then
  POOL=${DEFAULT_POOLNAME}
fi

for DEVICE in ${DEVICES}; do
  # destroy a GUID partition table on disk
  gpart destroy -F ${DEVICE}
done

DISKNO=1
VDEVICES=""
for DEVICE in ${DEVICES}; do
  # create a GUID partition table on disk
  gpart create -s gpt ${DEVICE}
  # create ZFS partition
  gpart add -t freebsd-zfs -a 4k -l disk$DISKNO ${DEVICE}
  # create virtual device which define 4K sector size
  gnop create -S 4096 /dev/gpt/disk$DISKNO

  VDEVICES="${VDEVICES} /dev/gpt/disk$DISKNO.nop"
  let DISKNO=DISKNO+1
  echo
done

# create ZFS pool
zpool create ${POOL} mirror ${VDEVICES}

# add l2arc
if [ -c "/dev/gpt/log" ]; then
  gnop create -S 4096 /dev/gpt/log
  zpool add ${POOL} log /dev/gpt/log.nop
fi

# add zil
if [ -c "/dev/gpt/cache" ]; then
  gnop create -S 4096 /dev/gpt/cache
  zpool add ${POOL} cache /dev/gpt/cache.nop
fi

zfs set checksum=fletcher4 ${POOL}
zfs set atime=off ${POOL}
zfs set dedup=off ${POOL}

# list snapshots
zpool set listsnapshots=on ${POOL}
