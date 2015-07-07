# bsdbox

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

## Credits

## License

Copyright 2014-2015 Alexander Wolff, Licensed under the MIT License.
