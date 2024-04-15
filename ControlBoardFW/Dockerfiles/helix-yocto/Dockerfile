FROM helix as helix-yocto

# Install required packages
RUN apt update -yqq
RUN apt dist-upgrade -yqq
RUN apt install -yqq git cmake gcc g++ gdb emacs gparted gitk git-lfs 
RUN apt install -yqq libstdc++6:i386 libgtk2.0-0:i386 dpkg-dev:i386 python3-pip libtinfo5 libncurses5 libtinfo6 libtinfo-dev
RUN apt install -yqq gawk xterm autoconf libtool texinfo gcc-multilib net-tools
RUN apt install -yqq repo pv libi2c-dev
RUN apt install -yqq chrpath diffstat zstd lz4
RUN apt install -yqq libgpiod-dev libssl-dev
RUN apt install -yqq gnuplot

ENTRYPOINT ["/bin/bash", "-c"]
