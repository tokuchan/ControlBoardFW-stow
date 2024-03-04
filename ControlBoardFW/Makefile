#. =Build ControlBoardFW inside a docker image.
.PHONY: all
all::

.PHONY: clean
clean::

.PHONY: distclean
distclean::

define cmake-opts
-DLOCAL_COMPILE=On
-DUSE_KELVIN_JR=On
-DUSE_AUTOTUNER=On
-DJANSSON_BUILD_DOCS=Off
-DBUILD_DOC=Off"
endef

define docker
docker run --rm -it -w $(top) -v$(top):$(top) 
endef

top := $(shell git rev-parse --show-toplevel)

build:
	mkdir $(top)/build
	cd build && cmake $(cmake-opts) ..
	make -C $(top)/build

all:: build

build-clean:
	make -C $(top)/build clean

clean:: build-clean

build-distclean:
	rm -rf $(top)/build

distclean:: build-distclean
