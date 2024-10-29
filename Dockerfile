FROM scratch
MAINTAINER Maxime Werlen <maxime@werlen.fr>
ENV DEBIAN_FRONTEND noninteractive

ENV TERM xterm
ARG DEBIAN_VERSION="sid"
ADD rootfs-${DEBIAN_VERSION}.tar.xz /

# Installing some dependencies
RUN apt-get update --fix-missing \
    && apt-get dist-upgrade -y \
    && apt-get install -y build-essential devscripts dh-make python3 \
            quilt pbuilder sbuild lintian git-buildpackage debootstrap apt-file apt-utils \
            fakeroot dh-autoreconf vim less locales autopkgtest \
    && apt-get autoremove -y

# Fixing timezone
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# set locale
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Creating mwerlen user and config
RUN mkdir /debian /home/mwerlen

COPY home /home/mwerlen/

RUN chown -R 1000:1000 /home/mwerlen

RUN adduser --disabled-password --gecos '' mwerlen
RUN adduser mwerlen sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER mwerlen

CMD ["/bin/bash"]
