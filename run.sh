docker run \
    --cap-add SYS_ADMIN \
    --security-opt apparmor:unconfined \
    -it \
    --rm \
    --volume /home/mwerlen/projects/debian/:/debian \
    --name debtest mwerlen/debian-sid:latest \
    /bin/bash
