#. = Helix Dockerfile

#. Sean R. Spillane

#. == Introduction

#. This dockerfile specifies a build environment for building the "yocto" build,
# which is an all-up build of the entire control system software for the miner.
# It requires several prerequisite tools several of which are a bit awkward to
# install. Therefore, while some of the process can be automated, in the end,
# the user will have to run this image with a particular set of volume mounts in
# order for it to be able to see and use the specialized tooling.

#. == Preamble

#. The helix image already sets up a build environment with GCC 9.3, and a host
# of needed tools. This will provide a good starting point for the yocto
# environment.

FROM helix as helix-yocto

#. == Install Ubuntu packages

#. While some of these packages are already present in the helix image, I chose
# to keep them here for documentary purposes. The original list was lifted from
# the
# #link("https://docs.google.com/document/d/141S2OB0g4FXMLJUE4GTybv_2WUaYiyzcpEQCeijuKng/edit?usp=sharing")[_Machine
# Setup to Build Firmware_] Google document.

RUN apt update -yqq
RUN apt dist-upgrade -yqq
RUN apt install -yqq git cmake gcc g++ gdb emacs gparted gitk git-lfs \
&& apt install -yqq lib32stdc++6 libgtk2.0-0 dpkg-dev python3-pip libtinfo5 libncurses5 libtinfo6 libtinfo-dev \
&& apt install -yqq gawk xterm autoconf libtool texinfo gcc-multilib net-tools \
&& apt install -yqq repo pv libi2c-dev \
&& apt install -yqq chrpath diffstat zstd lz4 \
&& apt install -yqq libgpiod-dev libssl-dev \
&& apt install -yqq gnuplot stow rsync bc build-essential language-pack-en

#. == Ensuring that Vivado and Petalinux are available

#. In order to complete a build, two pieces of software are required. Both are installed manually using a
# specialized installer binary which will download and install the required files. The steps required
# here are borrowed from the aforementioned Google document, under section 5 _Download Xilink Web Installer_.

#. 1. Create a xilink (AMD) account.
# 2. Download the `Xilinx_Unified_2023.1_0507_1903_Lin64.bin` installer from the
#    #link("https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2023-1.html")[_AMD
# Vivado download page_].
# 3. Run chmod u+x <path-to-Xilinx_Unified_2023.1_0507_1903_Lin64.bin> to make it executable.
# 4. By default, the installer will install to `/tools/Xilinx`. You can e.g.
#    `sudo mkdir -p /tools/Xilinx && sudo chown $(id -u).$(id -g)` to create
#    #footnote[This assumes that you use `bash`.] a directory there in your
#    name. Alternatively, you can point the installer to the directory of your
#    choice. In that case, wherever this document mentions `/tools/Xilinx`,
#    substitute your choice.
# 5. Start the installer and install Vivado Standard Edition #footnote[You will
#    require your AMD credentials in order to run this program.].
# 6. Start the installer and install Petalinux for ARM #footnote[You _can_
#    install all architectures, but that is superfluous.].

#. Subsequent docker instructions will assume that you have performed these
# steps. Therefore, ensure the following files exist:
# - `/tools/Xilinx/Vivado/2023.1/settings64.sh`
# - `/tools/Xilinx/PetaLinux/2023.1/tool/settings.sh`

#. Now, we'll update our entrypoint's login files to source the required pieces.

RUN echo 'source /tools/Xilinx/Vivado/2023.1/settings64.sh' >> /etc/bash.bashrc \
&& echo 'source /tools/Xilinx/PetaLinux/2023.1/tool/settings.sh' >> /etc/bash.bashrc

#. Next, we have to switch the default shell.

RUN echo "dash dash/sh boolean false" | debconf-set-selections \
&& dpkg-reconfigure --frontend=noninteractive dash

#. == Per-user configuration

#. This step sets up git identities so that the `repo` commands will work. For
# now, user name and email are hardcoded, but I intend to make them into
# parameters at some point. For now, just change them to suit.

RUN git config --global user.name "Sean R. Spillane" \
&& git config --global user.email "tokuchan@gmail.com" \
&& git config --global credential.helper store

#. == Define entrypoint

ENTRYPOINT ["/bin/bash", "-c"]
