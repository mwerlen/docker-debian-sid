#!/bin/bash
set -eu

version="${1:-sid}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ `find . -name "rootfs-${version}.tar.xz" -mtime -3 | wc -l` -eq 1 ]]; then
    echo "Existing recent rootfs, using it !"
else
    echo "Need to rebuild rootfs"
    if [[ -d "${DIR}/rootfs-${version}" ]]; then
        # If an existing rootfs directory exists, we need to delete it to avoid using an old cache
        sudo rm -r "${DIR}/rootfs-${version}"
    fi
    # Downloading base debian image
    sudo debootstrap ${version} "rootfs-${version}" https://ftp.debian.org/debian \
        || sudo debootstrap ${version} "rootfs-${version}" http://debian.mirrors.ovh.net/debian \
        || ( sudo debootstrap --no-check-gpg ${version} "rootfs-${version}" http://ftp.debian.org/debian && echo "deboostrap done whitout GPG check !")

    # Preparing base image
    sudo tar -C "rootfs-${version}" -cf "rootfs-${version}.tar" .
    sudo chown mwerlen:mwerlen "rootfs-${version}.tar"
    sudo rm -rf "rootfs-${version}"
    xz -f "rootfs-${version}".tar
fi

# Download current server .urlwatch folder
scp -r server:/home/mwerlen/.urlwatch/{cache.db,urls.yaml,urlwatch.yaml} ${DIR}/home/.urlwatch

# Building with docker
docker build --build-arg DEBIAN_VERSION="${version}" -t mwerlen/debian-${version} .

if [[ ! -f "$DIR/pbuilder-${version}/base.tgz" ]];  then
# Creating or updating base.tgz for pbuilder

    echo "Preparing pbuilder base.tgz"
    
    docker run \
        --cap-add SYS_ADMIN \
        --security-opt apparmor:unconfined \
        -it \
        --rm \
        --volume "$DIR/pbuilder-${version}":/pbuilder \
        --name pbuilder-create mwerlen/debian-${version}:latest \
        sudo pbuilder \
            --create \
            --basetgz /pbuilder/base.tgz \
            --distribution ${version} \
            --architecture amd64 \
            --mirror http://ftp.debian.org/debian \
            --debootstrapopts "--keyring=/usr/share/keyrings/debian-archive-keyring.gpg"

elif [[ `find "$DIR/pbuilder-${version}/" -iname "base-${version}.tgz" -mtime +3 | wc -l` -eq 1 ]]; then
# Updating pbuilder base.tgz
    
    echo "Need to update pbuilder base.tgz"

    docker run \
        --cap-add SYS_ADMIN \
        --security-opt apparmor:unconfined \
        -it \
        --rm \
        --volume "$DIR/pbuilder-${version}":/pbuilder \
        --name pbuilder-update mwerlen/debian-${version}:latest \
        sudo pbuilder \
            --update \
            --basetgz /pbuilder/base.tgz \
            --distribution ${version} \
            --architecture amd64 \
            --mirror http://ftp.debian.org/debian \
            --debootstrapopts "--keyring=/usr/share/keyrings/debian-archive-keyring.gpg"
else
    echo "Using existing recent pbuilder base.tgz"
fi

