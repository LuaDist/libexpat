CMAKE_BUILD_DIR ?= work
SOURCE_DIR := $(shell pwd)

VENDOR_INSTALL_PREFIX ?= $(SOURCE_DIR)
ifneq ($(VENDOR_INSTALL_PREFIX),"")
	CMAKE_PLATFORM_DEFINES := -D CMAKE_INSTALL_PREFIX=$(VENDOR_INSTALL_PREFIX)
	CMAKE_PLATFORM_DEFINES += -D CMAKE_OSX_ARCHITECTURES=i386
endif

.PHONY: install
install: build
	$(MAKE) -C $(CMAKE_BUILD_DIR) install

.PHONY: default
default: install

.PHONY: clean
clean:
	$(MAKE) -C $(CMAKE_BUILD_DIR) clean

.PHONY: mrproper
mrproper:
	rm -rf $(CMAKE_BUILD_DIR)

build: configure
	$(MAKE) -C $(CMAKE_BUILD_DIR)
	
configure: setup
	cd $(CMAKE_BUILD_DIR) && cmake $(CMAKE_PLATFORM_DEFINES) $(SOURCE_DIR)

setup:
	mkdir -p $(CMAKE_BUILD_DIR)

