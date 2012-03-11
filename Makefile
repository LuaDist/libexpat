CMAKE_BUILD_DIR ?= work

ifneq ($(CMAKE_INSTALL_PREFIX),"")
	CMAKE_PLATFORM_DEFINES := -D CMAKE_INSTALL_PREFIX=../../
endif

.PHONY: install
install: build
	$(MAKE) -C $(CMAKE_BUILD_DIR) install

.PHONY: default
default: install

build: configure
	$(MAKE) -C $(CMAKE_BUILD_DIR)
	
configure: setup
	cd $(CMAKE_BUILD_DIR) && cmake $(CMAKE_PLATFORM_DEFINES) ..

setup:
	mkdir -p $(CMAKE_BUILD_DIR)

