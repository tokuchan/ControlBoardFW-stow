FROM ubuntu:24.04 as base
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update \
&& yes | unminimize
RUN apt-get update \
&& apt-get -yqq install curl build-essential manpages-dev libgmp-dev libmpfr-dev libmpc-dev gcc-9 g++-9 gcc-12 g++-12 gcc-14 g++-14 cmake libgpiod-dev libi2c-dev git netcat-openbsd gdb graphviz doxygen man man-db bat less libstdc++6
ENV MANPAGER=/usr/bin/batcat
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100 --slave /usr/bin/g++ g++ /usr/bin/g++-12 --slave /usr/bin/gcov gcov /usr/bin/gcov-12
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 95 --slave /usr/bin/g++ g++ /usr/bin/g++-14 --slave /usr/bin/gcov gcov /usr/bin/gcov-14
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 85 --slave /usr/bin/g++ g++ /usr/bin/g++-13 --slave /usr/bin/gcov gcov /usr/bin/gcov-13
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 80 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9
RUN update-alternatives --auto gcc

# If I need to be able to cross-compile, I'll need to build my own gcc.
#FROM base as gcc-9
#RUN mkdir -p /gcc/target/share
#WORKDIR /gcc
#RUN curl -O https://mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-9.3.0/gcc-9.3.0.tar.xz
#RUN tar -x --no-same-owner --no-same-permissions -f gcc-9.3.0.tar.xz
#RUN echo "enable_silent_rules=yes" >> /gcc/target/share/config.site
#WORKDIR /gcc/gcc-9.3.0
##ENV GLIBCDIR=/usr
##ENV CFLAGS="-L $GLIBCDIR/lib/x86_64-linux-gnu -I $GLIBCDIR/include -Wl,--rpath=$GLIBCDIR/lib/x86_64-linux-gnu -Wl,--dynamic-linker=/usr/lib/ld-linux.so.2"
##ENV LDFLAGS="-Wl,-q"
#RUN ./configure --prefix=/gcc/target --disable-multilib
#RUN make all -j30
#RUN make install
#RUN cd /gcc/target && tar -c --no-same-owner --no-same-permissions -f /gcc/gcc-9.tar ./


FROM base as helix
RUN apt-get update
RUN apt-get --fix-missing -yqq install jq miller valgrind
#RUN update-alternatives --set gcc $(update-alternatives --list gcc | grep 9)
#RUN update-alternatives --set gcc $(update-alternatives --list gcc | grep 14)
#COPY --from=gcc-9 /gcc/gcc-9.tar /usr/local/
#RUN cd /usr/local && tar -x --no-same-owner --no-same-permissions -f gcc-9.tar
#RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9.3.0 80 --slave /usr/bin/g++ g++ /usr/bin/g++-9.3.0 --slave /usr/bin/gcov gcov /usr/bin/gcov-9.3.0
#RUN update-alternatives --set $(update-alternatives --list gcc | grep 9.3.0)
ENTRYPOINT ["/bin/bash", "-c"]
