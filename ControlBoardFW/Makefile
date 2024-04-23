#. =Build ControlBoardFW inside a docker image.
#. The `build-image` variable specifies the build image to use.
build-image:=helix

#. Specify the master targets, and the default target.
.PHONY: all # Build the default targets.
all::

.PHONY: test # Build and test the default targets.
test:: all

.PHONY: clean # Remove build files and built executables.
clean::

.PHONY: distclean # Restore the repo to pristine state.
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
docker run --rm -it -w $(top) -v$$HOME:$$HOME -v$(top):$(top) -t $(build-image) '$1'
endef

.build-environment: .build-environment-$(build-image)
	touch $@

.build-environment-$(build-image):
	docker build $(top) --tag=$(build-image) --file=$(top)/Dockerfiles/$(build-image)/Dockerfile
	touch $@

.PHONY: .build-environment-clean # Clean build environment marker files.
.build-environment-clean:
	rm -f .build-environment*

all:: .build-environment
clean:: .build-environment-clean

.PHONY: shell # Open a shell within the build environment.
shell: .build-environment
	$(call docker,bash)

top := $(shell git rev-parse --show-toplevel)

#. = Define documentation targets
.PHONY: doxygen # Build documentation.
doxygen:
	cd $(top) && doxygen

all:: doxygen

.PHONY: doxygen-clean # Clean up built documentation.
doxygen-clean:
	rm -rf $(top)/doxygen

clean:: doxygen-clean

#. = Define build targets
.PHONY: build # Build default targets.
build:: .build-environment
all:: build
test:: opts:=""
test:: build
	cd $(top)/target/build && ctest --output-on-failure --no-tests=error $(opts)

target/build:
	mkdir -p $(top)/target/build

target/build/Makefile: target/build
	$(call docker,cd $(top)/target/build && cmake $(cmake-opts) ../..)

.PHONY: build-target # Run the cmake-generated Makefile in the build environment.
build-target: target/build/Makefile
	$(call docker,cmake --build $(top)/target/build --parallel=20)

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

