FROM debian:sid

MAINTAINER Maxime Werlen <maxime@werlen.fr>
ENV DEBIAN_FRONTEND noninteractive

ENV TERM xterm

# Installing some dependencies
RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y build-essential devscripts dh-make dh-python python3 debhelper \
            quilt pbuilder sbuild lintian git-buildpackage debootstrap apt-file apt-utils \
            fakeroot dh-autoreconf vim less locales \
    && apt-get autoremove -y

# Fixing timezone
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Creating mwerlen user and config
RUN mkdir /debian /home/mwerlen

COPY home/.bash_aliases \
     home/.bash_profile \
     home/.bashrc \
     home/.gitconfig \
     home/.profile \
     home/.screenrc \
     home/.quiltrc \
     home/.vimrc \
     /home/mwerlen/

COPY pbuilder/pbuilderrc /etc/pbuilderrc

RUN chown -R 1000:1000 /home/mwerlen

RUN adduser --disabled-password --gecos '' mwerlen
RUN adduser mwerlen sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER mwerlen

# Copying pbuilder base image
COPY pbuilder/base.tgz /var/cache/pbuilder

CMD ["/bin/bash"]
