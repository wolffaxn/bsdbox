#!/usr/bin/env sh
#
# Postinstall script
#
# Copyright (c) 2015 Alexander Wolff <wolffaxn[at]gmail[dot]com>

set -e
# set -x

REPO_URL="https://raw.github.com/wolffaxn/bsdbox/master"

# setup pkgng
pkg update -y
pkg upgrade -y

# convert your /var/db/pkg database to the new pkg format
pkg2ng

pkg install -y bash
pkg install -y sudo
pkg install -y virtualbox-ose-additions

# create vagrant user
pw useradd -n vagrant -s /usr/local/bin/bash -m -G wheel -h 0 <<EOC
vagrant
EOC

# enable sudo for this user
echo "%vagrant ALL=(ALL) NOPASSWD: ALL" >> /usr/local/etc/sudoers

# loader.conf
fetch --no-verify-peer -o /boot/loader.conf $REPO_URL/boot/loader.conf
# sshd_config
fetch --no-verify-peer -o /etc/ssh/sshd_config $REPO_URL/etc/ssh/sshd_config
# hosts
fetch --no-verify-peer -o /etc/hosts $REPO_URL/etc/hosts
# make.conf
fetch --no-verify-peer -o /etc/make.conf $REPO_URL/etc/make.conf
# motd
fetch --no-verify-peer -o /etc/motd $REPO_URL/etc/motd
# rc.conf
fetch --no-verify-peer -o /etc/rc.conf $REPO_URL/etc/rc.conf
# resolv.conf
fetch --no-verify-peer -o /etc/resolv.conf $REPO_URL/etc/resolv.conf

# remove the history
cat /dev/null > /root/.history

# clean iup installed packages
pkg clean -a -y

# reduce *.vdi size
echo "Zero out all data to reduce box size..."
dd if=/dev/zero of=/tmp/ZEROES bs=1M
rm -rf /tmp/*

echo "Done! Poweroff the box and package it up with vagrant."
