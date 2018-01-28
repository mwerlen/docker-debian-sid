FROM debian:sid

MAINTAINER Maxime Werlen <maxime@werlen.fr>
ENV DEBIAN_FRONTEND noninteractive

ENV TERM xterm
RUN apt-get update && \
    apt-get dist-upgrade -y

RUN apt-get install -y build-essential devscripts dh-make dh-python python3 debhelper \
            quilt pbuilder sbuild lintian git-buildpackage debootstrap apt-file apt-utils \
            fakeroot dh-autoreconf

RUN apt-get install -y vim less \
    && apt-get autoremove -y

RUN mkdir /debian /home/mwerlen

COPY home/.bash_aliases \
     home/.bash_profile \
     home/.bashrc \
     home/.gitconfig \
     home/.profile \
     home/.screenrc \
     home/.quiltrc \
     /home/mwerlen/

COPY pbuilder/pbuilderrc /etc/pbuilderrc

RUN chown -R 1000:1000 /home/mwerlen

RUN adduser --disabled-password --gecos '' mwerlen
RUN adduser mwerlen sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER mwerlen

COPY pbuilder/base.tgz /var/cache/pbuilder
CMD ["/bin/bash"]
