#. =Build ControlBoardFW inside a docker image.
#. The `build-image` variable specifies the build image to use.
build-image:="helix"

#. Specify the master targets, and the default target.
.PHONY: all
all::

.PHONY: test
test:: all

.PHONY: clean
clean::

.PHONY: distclean
distclean::

define cmake-opts
-DLOCAL_COMPILE=Off \
-DUSE_KELVIN_JR=On \
-DUSE_AUTOTUNER=Off \
-DJANSSON_BUILD_DOCS=Off \
-DBUILD_DOC=Off \
-DINHIBIT_SUBMODULES=Off \
-DINHIBIT_TAR_PROJECT=Off
endef

define docker
docker run --rm -it -w $(top) -v$(top):$(top) -t $(build-image) '$1'
endef

.build-environment: .build-environment-$(build-image)

.build-environment-$(build-image):
	docker build $(top) --tag=$(build-image) --file=$(top)/Dockerfiles/$(build-image)/Dockerfile
	touch $@

.PHONY: .build-environment-clean
.build-environment-clean:
	rm -f .build-environment*

all:: .build-environment
clean:: .build-environment-clean

.PHONY: shell
shell: .build-environment
	$(call docker,bash)

top := $(shell git rev-parse --show-toplevel)

#. = Define documentation targets
.PHONY: doxygen
doxygen:
	cd $(top) && doxygen

all:: doxygen

.PHONY: doxygen-clean
doxygen-clean:
	rm -rf $(top)/doxygen

clean:: doxygen-clean

#. = Define build targets
.PHONY: build
build:: .build-environment
all:: build
test:: opts:=""
test:: target/build
	cd $(top)/target/build && ctest --output-on-failure --no-tests=error $(opts)

target/build:
	mkdir -p $(top)/target/build

target/build/Makefile: target/build
	$(call docker,cd $(top)/target/build && cmake $(cmake-opts) ../..)

.PHONY: build-target
build-target: target/build/Makefile
	$(call docker,cmake --build $(top)/target/build --parallel=20)

build:: build-target

.PHONY: build-clean
build-clean:
	make -C $(top)/target/build clean

clean:: build-clean

.PHONY: build-distclean
build-distclean:
	rm -rf $(top)/target

distclean:: build-distclean
