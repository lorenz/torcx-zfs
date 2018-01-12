#!/bin/bash
if [ "$(id -u)" != "0" ]; then
  exec sudo "$0" "$@" 
fi

source /run/metadata/torcx
export LD_LIBRARY_PATH=$TORCX_UNPACKDIR/zfs/lib:$TORCX_UNPACKDIR/zfs/lib64
export PATH=$PATH:$TORCX_UNPACKDIR/zfs/sbin:$TORCX_UNPACKDIR/zfs/bin
exec $TORCX_UNPACKDIR/zfs/sbin/COMMAND "$@"