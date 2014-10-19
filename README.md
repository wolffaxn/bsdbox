# bsdbox

These are FreeBSD configuration files for my HP N54L MicroServer.

## Install FreeBSD root on ZFS

```bash
cd /tmp
# download create-zfs-root.sh from github
fetch --no-verify-peer https://raw.github.com/wolffaxn/freebsd-server/master/create-zfs-root.sh
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
fetch --no-verify-peer https://raw.github.com/wolffaxn/freebsd-server/master/create-zfs-pool.sh
chmod 750 create-zfs-pool.sh
./create-zfs-pool.sh -d ada0 -d ada1 -d ada2 -d ada3 -p zstore
exit
```
