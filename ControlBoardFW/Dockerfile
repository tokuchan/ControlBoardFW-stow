FROM ubuntu:22.04 as base
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update \
&& apt-get -qq install curl build-essential libgmp-dev libmpfr-dev libmpc-dev

FROM base as helix
RUN apt-get -qq install cmake libgpiod-dev libi2c-dev
ENTRYPOINT ["/bin/bash", "-c"]
