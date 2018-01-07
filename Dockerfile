FROM debian:sid

MAINTAINER Maxime Werlen <maxime@werlen.fr>
ENV DEBIAN_FRONTEND noninteractive

ENV TERM xterm
RUN apt-get update && \
    apt-get dist-upgrade -y

RUN apt-get install -y build-essential devscripts dh-make dh-python python3 debhelper \
            quilt pbuilder sbuild lintian git-buildpackage debootstrap apt-file apt-utils \
            fakeroot dh-autoreconf

RUN apt-get install -y vim less more \
    && apt-get autoremove

COPY home/.bash_aliases \
     home/.bash_profile \
     home/.bashrc \
     home/.gitconfig \
     home/.profile \
     home/.screenrc \
     home/.quiltrc \
     /root/

RUN mkdir /debian

CMD ["/bin/bash"]
