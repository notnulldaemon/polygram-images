#!/bin/bash
echo "Polygram Debian Image Builder"
SIZE="8G"
#FILENAME="polygram-debian-$(date +%Y_%m_%d-%k_%M).img"
FILENAME="polygram-debian.img"
ROOT_PASS="polygram"

[ "$UID" != "0" ] && exit 1
fallocate -l "$SIZE" "$FILENAME"
mkfs.ext4 "$FILENAME"
mount "$FILENAME" /mnt
debootstrap bookworm /mnt http://deb.debian.org/debian || exit 1

echo "/dev/ubd0   ext4    discard,errors=remount-ro  0       1" | tee /mnt/etc/fstab
cp ../files/polygram-init-network /mnt/usr/bin
echo "nameserver 10.0.2.3" >/mnt/etc/resolv.conf
echo "polygram" >/mnt/etc/hostname
chmod u+x /mnt/usr/bin/polygram-init-network
cp ../files/polygram-network.service /mnt/etc/systemd/system
chroot /mnt /bin/sh -c "apt update && apt install neofetch -y --no-install-recommends && apt install dbus dbus-x11"
chroot /mnt systemctl enable polygram-network
chroot /mnt /bin/sh -c "echo 'root:$ROOT_PASS' | chpasswd"
umount /mnt

tar -czvf "$FILENAME.tar.gz" "$FILENAME"
