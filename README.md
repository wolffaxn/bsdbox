# bsdbox

These are FreeBSD configuration files for my HP N54L MicroServer.

## Install FreeBSD root on ZFS

```bash
cd /tmp
# download create-zfs-root.sh from github
fetch --no-verify-peer https://raw.github.com/wolffaxn/bsdbox/master/create-zfs-root.sh
chmod 750 create-zfs-root.sh
./create-zfs-root.sh -d ada4 -p zroot -r 64GB -s 2GB -l 8GB -z 16GB
exit
```

```bash
mount -t devfs devfs /dev
zfs set readonly=on zroot/var/empty
exit
```

```bash
cd /tmp
# download create-zfs-pool.sh from github
fetch --no-verify-peer https://raw.github.com/wolffaxn/bsdbox/master/create-zfs-pool.sh
chmod 750 create-zfs-pool.sh
./create-zfs-pool.sh -d ada0 -d ada1 -d ada2 -d ada3 -p zstore
exit
```

## Compile kernel

```bash
# download kernel sources
cd /usr/src
fetch ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/10.0-RELEASE/src.txz
tar -C / -xvzf src.txz

# compile kernel
cd /usr/src
make clean
make buildkernel KERNCONF=HPN54L
make installkernel KERNCONF=HPN54L
make clean

# then reboot your system
reboot
```
## Install ports collection

```bash
# download a compressed snapshot of the ports collection into /var/db/portsnap
portsnap fetch

# extract the snapshot into /usr/ports (for the first time only)
portsnap extract

portsnap fetch update
```
## Install portmaster

```bash
# install portmaster
cd /usr/ports/ports-mgmt/portmaster/
make install clean

# enable PKGNG as your package format
echo 'WITH_PKGNG=yes' >> /etc/make.conf

# convert your /var/db/pkg database to the new pkg format
pkg2ng
```
## Install additional ports

```bash
cd /usr/ports
pkg install devel/git
pkg install editors/vim-lite
pkg install security/sudo
pkg install sysutils/beadm
pkg install sysutils/jail2
```
## Create base jail

```bash
# create a ZFS dataset for FreeBSD base jail
zfs create -o mountpoint=/jails zstore/jails
zfs create zstore/jails/base10x64

# install the FreeBSD userland into FreeBSD base jail
cd /tmp/
fetch ftp://ftp.de.freebsd.org/pub/FreeBSD/releases/amd64/amd64/10.0-RELEASE/base.txz
tar -C /jails/base10x64 -xvzf base.txz

cp /etc/make.conf /jails/base10x64/etc/
cp /etc/motd /jails/base10x64/etc/
cp /etc/resolv.conf /jails/base10x64/etc/
chroot /jails/base10x64
passwd
mkdir /usr/ports
mkdir /usr/home
ln -s /usr/home /home
freebsd-update fetch install
```
