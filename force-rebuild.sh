sudo debootstrap sid rootfs http://ftp.debian.org/debian
sudo tar -C rootfs -cf rootfs.tar .
sudo chown mwerlen:mwerlen rootfs.tar
sudo rm -rf rootfs
xz -f rootfs.tar
docker build --no-cache  -t mwerlen/debian-sid .
