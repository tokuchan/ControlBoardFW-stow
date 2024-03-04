FROM ubuntu:22.04
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update \
&& apt-get -qq install curl \
&& apt-get -qq install libgpiod-dev build-essential cmake gcc-9 g++-9
ENTRYPOINT ["/bin/bash", "-c"]
