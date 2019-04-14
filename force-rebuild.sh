#!/bin/bash
set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ `find . -name 'rootfs.tar.xz' -mtime -3 | wc -l` -eq 1 ]]; then
    echo "Existing recent rootfs, using it !"
else
    echo "Need to rebuild rootfs"
    # Downloading base debian image
    sudo debootstrap sid rootfs http://ftp.debian.org/debian \
        || sudo debootstrap sid rootfs http://debian.mirrors.ovh.net/debian \
        || ( sudo debootstrap --no-check-gpg sid rootfs http://ftp.debian.org/debian && echo "deboostrap done whitout GPG check !")

    # Preparing base image
    sudo tar -C rootfs -cf rootfs.tar .
    sudo chown mwerlen:mwerlen rootfs.tar
    sudo rm -rf rootfs
    xz -f rootfs.tar
fi

# Building with docker
docker build -t mwerlen/debian-sid .

if [[ ! -f "$DIR/pbuilder/base.tgz" ]];  then
# Creating or updating base.tgz for pbuilder

    echo "Preparing pbuilder base.tgz"
    
    docker run \
        --cap-add SYS_ADMIN \
        --security-opt apparmor:unconfined \
        -it \
        --rm \
        --volume "$DIR/pbuilder":/pbuilder \
        --name pbuilder-create mwerlen/debian-sid:latest \
        sudo pbuilder \
            --create \
            --basetgz /pbuilder/base.tgz \
            --distribution sid \
            --architecture amd64 \
            --mirror http://ftp.debian.org/debian \
            --debootstrapopts "--keyring=/usr/share/keyrings/debian-archive-keyring.gpg"

elif [[ `find "$DIR/pbuilder/" -iname 'base.tgz' -mtime +3 | wc -l` -eq 1 ]]; then
# Updating pbuilder base.tgz
    
    echo "Need to update pbuilder base.tgz"

    docker run \
        --cap-add SYS_ADMIN \
        --security-opt apparmor:unconfined \
        -it \
        --rm \
        --volume "$DIR/pbuilder":/pbuilder \
        --name pbuilder-update mwerlen/debian-sid:latest \
        sudo pbuilder \
            --update \
            --basetgz /pbuilder/base.tgz \
            --distribution sid \
            --architecture amd64 \
            --mirror http://ftp.debian.org/debian \
            --debootstrapopts "--keyring=/usr/share/keyrings/debian-archive-keyring.gpg"
else
    echo "Using existing recent pbuilder base.tgz"
fi

