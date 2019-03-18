#!/bin/sh
coreosimg=$(mktemp /tmp/coreos-devel.XXXXXX)
wget -nv -O - https://$CHANNEL.release.core-os.net/amd64-usr/$VERSION/coreos_developer_container.bin.bz2 | bunzip2 > $coreosimg
dev=$(losetup -rPf --show $coreosimg)
rootmount=$(mktemp -d /tmp/coreos-devel.XXXXXX)
mount -t ext4 ${dev}p9 $rootmount -o ro
cd $rootmount
tar -cf - . | docker import - $IMAGE_NAME:$VERSION
umount -f $rootmount
losetup -d $dev
rm -f $coreosimg
rmdir $rootmount 