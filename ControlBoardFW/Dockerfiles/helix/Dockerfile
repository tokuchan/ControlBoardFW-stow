FROM ubuntu:22.04 as base
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update \
&& apt-get -qq install curl build-essential libgmp-dev libmpfr-dev libmpc-dev
RUN yes | unminimize
RUN apt-get -qq install man man-db bat less
ENV MANPAGER=/usr/bin/batcat

# If I need to be able to cross-compile, I'll need to build my own gcc.
FROM base as gcc-9
RUN mkdir -p /gcc
WORKDIR /gcc
RUN curl -O https://mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-9.3.0/gcc-9.3.0.tar.xz
RUN tar xf gcc-9.3.0.tar.xz
WORKDIR /gcc/gcc-9.3.0
RUN ./configure --prefix=/gcc/target --disable-multilib
RUN make all install
RUN cd /gcc/target && tar cf /gcc/gcc-9.tar ./


FROM base as helix
RUN apt-get -qq install cmake libgpiod-dev libi2c-dev git
COPY --from=gcc-9 /gcc/gcc-9.tar /usr/local/
RUN cd /usr/local && tar xf gcc-9.tar
ENTRYPOINT ["/bin/bash", "-c"]
