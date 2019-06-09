#!/bin/bash
set -ev

BUILDDIR=$(pwd)
mkdir root
mkdir udev

emerge-gitclone

if perl -V ; then
    echo "Not patching perl, it already works"
else
    echo "Patching perl, it's broken"
    patch $(equery w dev-lang/perl) perl-fwrapv-fix.patch
    emerge --nodep -e dev-lang/perl # VERY BAD, but this environment is going to get destroyed in a few minutes so whatever
fi

wget -q -O - https://github.com/zfsonlinux/zfs/releases/download/zfs-$ZOL_VERSION/zfs-$ZOL_VERSION.tar.gz | tar -xzf -

emerge -1 sys-devel/automake autoconf libtool dev-libs/elfutils --autounmask-write || emerge -1 sys-devel/automake autoconf dev-libs/elfutils libtool

ZOL_VERSION_DIR=$(echo $ZOL_VERSION | cut -f1 -d"-")

cd $BUILDDIR/zfs-$ZOL_VERSION_DIR
./autogen.sh
./configure --prefix=$BUILDDIR/root --with-linux=/usr/lib64/modules/$(ls /lib64/modules)/source --with-linux-obj=/usr/lib64/modules/$(ls /lib64/modules)/build --with-udevdir=$BUILDDIR/udev
automake
make -j$(nproc)
make install

cd $BUILDDIR
mkdir -p root/lib/modules
cp -a /lib64/modules/$(ls /lib64/modules)/extra/. root/lib/modules/

mkdir -p root/lib/systemd/system
cp -a *.service root/lib/systemd/system/
cp -a *.target root/lib/systemd/system/
mkdir -p root/lib/systemd/system/zfs.target.wants
ln -s ../zfs-mount.service root/lib/systemd/system/zfs.target.wants/zfs-mount.service
ln -s ../zfs-import-scan.service root/lib/systemd/system/zfs.target.wants/zfs-import-scan.service
ln -s ../zfs-import-cache.service root/lib/systemd/system/zfs.target.wants/zfs-import-cache.service
ln -s ../zfs-udev.service root/lib/systemd/system/zfs.target.wants/zfs-udev.service
mkdir -p root/lib/systemd/system/multi-user.target.wants
ln -s ../zfs.target root/lib/systemd/system/multi-user.target.wants/zfs.target

WRAP="fsck.zfs zdb zed zfs zpios zpool zstreamdump zvol_id vdev_id"

mkdir -p root/wrap
for command in $WRAP; do
    cp wrapper.sh root/wrap/$command
    sed -i "s|COMMAND|$command|g" root/wrap/$command
done

mkdir -p root/.torcx
cp manifest.json root/.torcx/manifest.json

mkdir -p root/etc/udev/rules.d
cp 60-zvol.rules root/etc/udev/rules.d/
cp 69-vdev.rules root/etc/udev/rules.d/
cp udev/zvol_id root/sbin/zvol_id
cp udev/vdev_id root/sbin/vdev_id

rm -Rf root/include
rm -Rf root/lib/*.a
rm -Rf root/src
rm -Rf root/share

cd root
tar --force-local -zcf ../zfs:$ZOL_VERSION.torcx.tgz .