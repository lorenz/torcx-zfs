#!/bin/bash
set -ev

BUILDDIR=$(pwd)
mkdir root

emerge-gitclone

wget -q -O - https://github.com/zfsonlinux/zfs/releases/download/zfs-$ZOL_VERSION/zfs-$ZOL_VERSION.tar.gz | tar -xzf -
wget -q -O - https://github.com/zfsonlinux/spl/archive/spl-$ZOL_VERSION.tar.gz | tar -xzf -

emerge automake autoconf libtool

cd $BUILDDIR/spl-spl-$ZOL_VERSION
./autogen.sh
./configure --prefix=$BUILDDIR/root  --with-linux=/usr/lib64/modules/$(ls /lib64/modules)/source --with-linux-obj=/usr/lib64/modules/$(ls /lib64/modules)/build
automake
make -j$(nproc)
make install

cd $BUILDDIR/zfs-$ZOL_VERSION
./autogen.sh 
./configure --prefix=$BUILDDIR/root --with-linux=/usr/lib64/modules/$(ls /lib64/modules)/source --with-linux-obj=/usr/lib64/modules/$(ls /lib64/modules)/build --with-spl=$BUILDDIR/spl-spl-$ZOL_VERSION/
automake
make -j$(nproc)
make install

cd $BUILDDIR
mkdir -p root/.torcx
cp manifest.json root/.torcx/manifest.json

cd root
tar --force-local -zcf ../zfs:$ZOL_VERSION.torcx.tgz .

#WRAP="fsck.zfs mount.zfs zdb zfs zhack zinject zpios zpool zstreamdump ztest vdev_id zvol_id"

#mkdir -p /target/bin
#mkdir -p /target/wrap
#for command in "$WRAP"; do
#    LOC=$(which $command)
#    cp wrapper.sh /target/wrap/$command
#    sed -i "s|COMMAND|$command|g" /target/wrap/$command
#    cp $LOC /target/bin/
#done