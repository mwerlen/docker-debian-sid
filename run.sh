#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker run \
    --cap-add SYS_ADMIN \
    --security-opt apparmor:unconfined \
    -it \
    --rm \
    --volume $HOME/.gnupg:/home/mwerlen/.gnupg \
    --volume $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) \
    --env SSH_AUTH_SOCK=$SSH_AUTH_SOCK \
    --volume /home/mwerlen/projects/debian/:/debian \
    --volume "$DIR/pbuilder/base.tgz":/var/cache/pbuilder/base.tgz \
    --volume "$DIR/pbuilderrc":/etc/pbuilderrc \
    --name debtest mwerlen/debian-sid:latest \
    gpg-agent --daemon --debug-pinentry --allow-loopback-pinentry /bin/bash
