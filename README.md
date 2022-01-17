# Torcx ZFS Module

:warning: **This is no longer maintained, we've switched to a fully custom OS. Feel free to fork.**

## Building

The build process currently requires guestfish and Docker. The base image can be generated as follows ($VERSION is the CoreOS release, for example 1576.5.0):
```sh
wget -qO - http://stable.release.core-os.net/amd64-usr/$VERSION/coreos_developer_container.bin.bz2 | bunzip2 > coreos_developer_container.bin
guestfish -i -a coreos_developer_container.bin tgz-out / - | docker import - your-registry.com/coreos-devel:$VERSION
docker push your-registry.com/coreos-devel:$VERSION
```

Instantiate a container from that image and copy the repository into it (or let a CI do that for you).
Then execute `env ZOL_VERSION=0.8.0 ./build.sh`. That will generate a torcx module for that specific CoreOS version
and ZFSOnLinux 0.8.0.

## Old ZoL versions
Master is only compatible with the latest major release of ZoL (currently 0.8). For older versions please use the corresponding branch.

## Installation

Take the resulting `zfs:0.8.0.torcx.tgz` file and either manually put it into
`/var/lib/torcx/store/$VERSION/` or have some orchestration system do that for you. 

Create a torcx manifest or extend your existing manifest (example below) and drop it in `/etc/torcx/profiles/some_manifest.json`.
```json
{
  "kind": "profile-manifest-v0",
  "value": {
    "images": [
      {
        "name": "zfs",
        "reference": "0.8.0"
      }
    ]
  }
}
```

Enable your manifest if you haven't already:
```sh
echo 'some_manifest' > /etc/torcx/next-profile
```

If you want to be able to use the ZFS CLI utils you need to add the Torcx PATH to your system path. Create an executable file in `/etc/profile.d/torcx-path.sh` with the following content:
```sh
# torcx drop-in: add torcx-bindir to PATH
export PATH="/var/run/torcx/bin:${PATH}"
```
You only need to do that once for all Torcx modules. This will hopefully no longer be necessary once Torcx is better integrated into CoreOS.

At that point you can reboot and enjoy ZFS on your CoreOS system :)

## FAQ
**Do I need to rebuild the module for every CoreOS release?**
Yes. Technically you can skip it if the Kernel release hasn't changed (not often), but I wouldn't.

**What can I do to make ZFS imports faster?**
By default this ZFSOnLinux doesn't use the ZFS import cache. You can enable it by executing `zpool set cachefile=/etc/zfs/zpool.cache <poolname>`, but please read up on the effects of doing that
