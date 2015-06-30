# bsdbox

Vagrant box with latest FreeBSD and ZFS.

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

## Install FreeBSD root on ZFS

```sh
dhclient vtnet0
```

```sh
cd /tmp
# download zfsinstall.sh from github
fetch --no-verify-peer https://raw.githubusercontent.com/wolffaxn/bsdbox/master/bin/zfsinstall.sh
chmod 750 zfsinstall.sh
./zfsinstall.sh -d ada4 -p zroot -r 8GB -s 2GB
exit
```

```sh
mount -t devfs devfs /dev
zfs set readonly=on zroot/var/empty
exit
```

## Package for Vagrant

```
vagrant package --base <name-of-your-virtual-machine> --output freebsd-10.1-amd64.box
```

## Credits

## License
