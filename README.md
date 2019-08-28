# bsdbox

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub last commit (branch)](https://img.shields.io/github/last-commit/wolffaxn/bsdbox/master.svg)](https://github.com/wolffaxn/bsdbox)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [About](#about)
- [Install FreeBSD root on ZFS](#install-freebsd-root-on-zfs)
- [Virtualbox Settings](#virtualbox-settings)
- [Package for Vagrant](#package-for-vagrant)
- [Setup](#setup)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## About 

Vagrant box with latest FreeBSD and ZFS.

## Install FreeBSD root on ZFS

1) Run

```sh
su -
```
to get a root shell.

2) Run DHCP client by running

```sh
dhclient vtnet0
```
to get an IPv4 address.

3) We can now start an SSH daemon by running:

```sh
mkdir /tmp/etc
mount_unionfs /tmp/etc /etc
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
passwd root
service sshd onestart
```

4) Login to the FreeBSD Shell by running:

```sh
ssh root@<ip_address>
```

5)

```sh
cd /tmp
# download zfsinstall.sh from github
fetch --no-verify-peer https://raw.github.com/wolffaxn/bsdbox/master/bin/zfsinstall.sh
chmod 750 zfsinstall.sh
./zfsinstall.sh -d ada0 -p zroot -r 8GB -s 2GB
```

```sh
shutdown -h now
```

```sh
cd /tmp
# download vagrant-setup.sh from github
fetch --no-verify-peer https://raw.github.com/wolffaxn/bsdbox/master/bin/vagrant-setup.sh
chmod 750 vagrant-setup.sh
./vagrant-setup.sh
```

## Virtualbox Settings

Create a new Virtual Machine with the following settings:

- System -> Motherboard -> Enable I/O APIC
- System -> Motherboard -> Hardware clock in UTC time
- System -> Processor -> 2 CPUs
- System -> Acceleration -> Enable VT-x/AMD-V
- System -> Acceleration -> Enable Nested Paging
- Storage -> Add SATA Controller
- Storage -> Attach a .vdi disk to SATA Port 0
- Audio -> Disable Audio
- Network -> Adapter 1 -> Attached to: NAT
- Network -> Adapter 1 -> Advanced -> Adapter Type -> Paravirtualized Network (virtio-net)
- Network -> Adapter 2 -> Attached to: host-only Adapter
- Network -> Adapter 2 -> Advanced -> Adapter Type -> Paravirtualized Network (virtio-net)
- Ports -> Disable Serial Port
- Ports -> Disable USB Controller

## Package for Vagrant

```
vagrant package --base <name-of-your-virtual-machine> --output freebsd-10.1-amd64.box
```

## Setup

1) Install dependencies

* [Vagrant](https://www.vagrantup.com) 1.7.2 or greater.
* [VirtualBox](https://www.virtualbox.org) 4.3.20 or greater.

2) Clone this project.

```
git clone https://github.com/wolffaxn/bsdbox.git
cd bsdbox
```

3) Install vagrant plugins

```
vagrant plugin install vagrant-cachier
vagrant plugin install vagrant-hostsupdater
vagrant plugin install vagrant-vbguest
```

4) Startup and SSH

```
vagrant up
vagrant ssh
```

## License

This project is licensed under the terms of the [MIT license](LICENSE).
