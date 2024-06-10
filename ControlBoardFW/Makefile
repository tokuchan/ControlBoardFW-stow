#. = Makefile

#. Sean\@Spillane.us

#. Define a build manager for helix firmware.

#. == Introduction

#. The best way to build the firmware is inside a dedicated docker or podman
# image. Since by default, I provide a docker interface, even if podman is the
# implementation, I standardize on the docker interface. This makefile defines a
# collection of handy rules, but does _not_ do any actual building of it's own.
# Instead, it will define a build environment, then kick off the build _inside_
# that environment by using docker, cmake, and another Makefile defined by cmake
# for us.

#. NOTE: The only tools that you should need to be able to use this build system
# are: either docker or podman, GNU make, and git. Git is used to fetch required
# repositories, docker or podman to handle the build environment, and make to
# coordinate everything. Make sure to run `make help` to see a list of available
# commands and additional user help.

#. == Locate the top-level directory

#. If this Makefile is run from within a git repo (typically the case for e.g.
# ControlBoardFW), then we use the `git rev-parse --show-toplevel` command to
# locate the top level directory. Otherwise (typically the case for a yocto
# build), we just use the current directory (assuming you ran `make` targeting
# the top level of the project).

top := $(shell git rev-parse --show-toplevel 2>/dev/null || pwd)

#. == Define default build image

#. By default, we use the `helix` build image, but if you define a file
# `.build-image`, with a single line of text inside, we'll use whatever _that_
# is as the build image instead.

build-image:=$(shell cat $(top)/.build-image 2>/dev/null || echo 'helix')

#. == Define primary targets

#. GNU Make offers a special kind of target, called double-colon rules. Unlike
# normal rules, where subsequent definitions override previous ones, with
# double-colon rules subsequent definitions _append_ to previous ones. I use this
# to define the "primary" targets that this Makefile offers. Specifically, a rule
# to build everything, a rule to test everything, and a rule to clean everything
# up.

.PHONY: all # Build the default targets.
all::

.PHONY: test # Build and test the default targets.
test:: all

.PHONY: clean # Remove build files and built executables.
clean::

.PHONY: distclean # Restore the repo to pristine state.
distclean::

#. == Define CMAKE options

#. Cmake requires several options be set in order to build. For now, I'm
# hard-coding these, but I will want to create "build profiles" later to
# abstract this out.

define cmake-opts
-DLOCAL_COMPILE=Off \
-DUSE_KELVIN_JR=On \
-DUSE_AUTOTUNER=Off \
-DJANSSON_BUILD_DOCS=Off \
-DBUILD_DOC=Off \
-DINHIBIT_SUBMODULES=Off \
-DINHIBIT_TAR_PROJECT=Off \
-DBUILD_TESTS=On
endef

#. == Define the build environment

#. This Makefile uses a docker image to manage the actual build. This allows me
# to abstract away specific tools and avoid polluting the dev system itself. To
# make this work, I define several `build-environment` rules. The first will
# build the _default_ build environment, as defined in `.build-image` or `helix`
# if no `.build-image` file obtains. The second rule contains the actual logic
# to run `docker build` properly on the selected build image. The final target
# removes the checkpoint files so that docker will be run again.

define docker
docker run --security-opt seccomp=unconfined --rm -it -w $(top) -v$$HOME:$$HOME:z -v$(top):$(top):z -t $(build-image) '$1'
endef

.build-environment: .build-environment-$(build-image)
	touch $@

.build-environment-$(build-image):
	docker build $(top) --security-opt seccomp=unconfined --tag=$(build-image) --file=$(top)/Dockerfiles/$(build-image)/Dockerfile
	touch $@

.PHONY: build-environment-clean # Clean build environment marker files.
build-environment-clean:
	rm -f .build-environment*

all:: .build-environment
clean:: build-environment-clean

#. == Define shell target

#. Once a build environment exists, it is good to be able to access a shell _within_ that
# environment. The following two rules make that convenient. The first rule will
# open a shell, building the environment if needed. The second rule just cleans
# the build environment then runs the first, forcing a rebuild of the build
# environment.

.PHONY: shell # Open a shell within the build environment.
shell: .build-environment
	$(call docker,bash)

.PHONY: rebuild-shell # Rerun docker build and open a shell within the build environment.
rebuild-shell: build-environment-clean shell

#. == Project documentation

#. Since this Makefile targets a C and C++ project, it is useful to support building documentation using
# Doxygen. Therefore the next two targets define building and cleaning rules for Doxygen.

.PHONY: doxygen # Build documentation.
doxygen:
	$(call docker,cd $(top) && doxygen)

all:: doxygen

.PHONY: doxygen-clean # Clean up built documentation.
doxygen-clean:
	rm -rf $(top)/doxygen

clean:: doxygen-clean

#. == Project building

#. Define a set of targets to actually build the project. The first target is a
# double-colon rule, like the primary targets above, named `build`. This allows
# me to attach addition build rules later on, for example for sub-projects or
# the like.

.PHONY: build # Build default targets.
build:: .build-environment
all:: build
test:: opts:=""
test:: build
	cd $(top)/target/build && ctest --output-on-failure --no-tests=error $(opts)

target/build:
	mkdir -p $(top)/target/build

#. === Generate the build system

target/build/Makefile: target/build
	$(call docker,cd $(top)/target/build && cmake $(cmake-opts) ../..)

#. The build-target sub target actually runs the build. Please note the scoped
# variable `parallel`, which specifies the number of concurrent processes to run
# when building. If you need to set that number explicitly, you can easily do so
# right on the command line: `make parallel=2 clean all`.

.PHONY: build-target # Run the cmake-generated Makefile in the build environment.
build-target: parallel:= 20
build-target: target/build/Makefile
	$(call docker,cmake --build $(top)/target/build --parallel=$(parallel))

build:: build-target

.PHONY: build-clean # Remove the target directory.
build-clean:
	rm -rf $(top)/target

clean:: build-clean

.PHONY: build-distclean # Remove the target directory.
build-distclean:
	rm -rf $(top)/target

.PHONY: rinse # Clean up the repo of untracked and uncommitted files, restore the submodules to pristine state.
rinse:
	git submodule foreach --recursive git clean -xfd
	git submodule sync --recursive
	git restore . --recurse-submodules

distclean:: build-distclean

#. === Help

#. This rule will print out a listing of non-hidden targets and their
# descriptions.

.PHONY: list-targets # List all targets in this Makefile
list-targets:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null \
		| awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
		| sort \
		| grep -E -v -e '^[^[:alnum:]]' -e '^$@$$' \
		| sort -u

.PHONY: help # Generate list of phony targets with descriptions
help:
	@grep '^.PHONY: .* #' Makefile \
		| sed 's/\.PHONY: \(.*\) # \(.*\)/\1\t\2/' \
		| expand -t20

#. === Internal documentation

#. This rule generates the PDF help you are viewing now. It allows me to write
# this Makefile in a "semi-literate" fashion, where I can use "special comment
# blocks" to typeset and format documentation for this Makefile.

#. The way this rule works is simple: First, look for lines that start with a
# hash, but aren't special comment blocks. By convention, these will be
# _continuations_ of special comment blocks, and so it is safe to simply strip
# those hashes and convert the lines to regular text. Next, feed the file to
# `awk -v RS= -v ORS="\n\n"`, which has the effect of grouping paragraphs into
# single matches. This is why documentation makes use of blank lines. Then, if a
# paragraph starts with a special comment block marker, strip that off and
# render the paragraph as normal text. Otherwise, surround the paragraph with
# triple backticks to turn it into a source block.

#. To render a source block for a different language, just embed it in a normal
# paragraph, like this:
# ``````
# ````cpp
# if (foo)
#   bar ();
# ````
# ``````
# which renders thus:
# ````cpp
# if (foo)
#   bar ();
# ````
# That way, weave won't see the sources, because I didn't include any blank
# lines to separate the paragraphs.

.PHONY: weave # Render this file as internal documentation
weave: Makefile.pdf

%.pdf: type:=Makefile
%.pdf: %.typst
	typst compile $< $@

%.typst: type:=Makefile
%.typst: %
	cat $< | sed 's,^# ,,g' | awk -v RS= -v ORS="\n\n" '!/#\. /{print "``""`$(type)\n"$$0"\n`""``\n"}; /^#\./{gsub("#\. ", "", $$0); print $$0}' > $@

#. == Yocto Build Targets

#. Yocto is a completely different animal from the normal build process. As
# such, the targets to handle it are treated specially. Basically, there's a
# script that does most of the work, and we need to ensure that all of the
# required dependencies are installed.

#. First, we must set and export the language to get the right locale.

export LANG=en_US.UTF-8

#. Vivado is picky about shells. Therefore, I have to use bash by default.

SHELL:= /bin/bash -l

#. Now we can define the special yocto targets.

.PHONY: yocto # Build the yocto project, starting with a repo-sync'ed directory.
yocto: yocto-install-dependencies yocto-verify-python yocto-full-build

.PHONY: yocto-install-dependencies # Install required packages
yocto-install-dependencies:
	./install-dependencies.sh

.PHONY: yocto-verify-python # Verify that python provides the correct packages
yocto-verify-python:
	python -c 'import distutils'

.PHONY: yocto-full-build # Run the bitstream and image builds
yocto-full-build:
	cd Linux && printf '1\n3\n' | ./scripts/run

.PHONY: yocto-clean # Clean the yocto build
yocto-clean:
	- cd Linux && printf '2\nY\n' | ./scripts/run
	- rm -f ./bitbake-cookerdaemon.log
	- find ./Linux/ -name bitbake.lock -exec rm {} \;

.PHONY: yocto-menu # Run the build script to get the menu
yocto-menu: yocto-install-dependencies yocto-verify-python
	cd Linux && ./scripts/run
