#. =Build ControlBoardFW inside a docker image.
.PHONY: all
all::

.PHONY: clean
clean::

.PHONY: distclean
distclean::

define cmake-opts
-DLOCAL_COMPILE=Off \
-DUSE_KELVIN_JR=On \
-DUSE_AUTOTUNER=Off \
-DJANSSON_BUILD_DOCS=Off \
-DBUILD_DOC=Off
endef

define docker
docker run --rm -it -w $(top) -v$(top):$(top) -t helix '$1'
endef

.PHONY: shell
shell:
	$(call docker,bash)

.PHONY: build-environment
build-environment:
	docker build $(top) --tag=helix

top := $(shell git rev-parse --show-toplevel)

#. = Define build targets
.PHONY: build
build::
all:: build

target/build:
	mkdir -p $(top)/target/build

target/build/Makefile: target/build
	$(call docker,cd $(top)/target/build && cmake $(cmake-opts) ../..)

.PHONY: build-target
build-target: target/build/Makefile
	$(call docker,make -C $(top)/target/build)

build:: build-target

.PHONY: build-clean
build-clean:
	make -C $(top)/target/build clean

clean:: build-clean

.PHONY: build-distclean
build-distclean:
	rm -rf $(top)/target

distclean:: build-distclean
