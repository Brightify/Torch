TEMPORARY_FOLDER?=/tmp/TorchGenerator.dst
PREFIX?=/usr/local
BUILD_TOOL?=xcodebuild

XCODEFLAGS=-project 'TorchGenerator.xcodeproj' -scheme 'TorchGenerator' DSTROOT=$(TEMPORARY_FOLDER)

BUILT_BUNDLE=$(TEMPORARY_FOLDER)/Applications/torch.app
TORCHGENERATOR_FRAMEWORK_BUNDLE=$(BUILT_BUNDLE)/Contents/Frameworks/TorchGeneratorFramework.framework
TORCHGENERATOR_EXECUTABLE=$(BUILT_BUNDLE)/Contents/MacOS/torch

FRAMEWORKS_FOLDER=$(PREFIX)/Frameworks
BINARIES_FOLDER=$(PREFIX)/bin

OUTPUT_PACKAGE=TorchGenerator.pkg
VERSION_STRING=$(shell agvtool what-marketing-version -terse1)
COMPONENTS_PLIST=Source/Supporting Files/Components.plist

.PHONY: all bootstrap clean install package test uninstall

all: 
	$(BUILD_TOOL) $(XCODEFLAGS) build

test: clean bootstrap
	$(BUILD_TOOL) $(XCODEFLAGS) test

clean:
	rm -f "$(OUTPUT_PACKAGE)"
	rm -rf "$(TEMPORARY_FOLDER)"
	$(BUILD_TOOL) $(XCODEFLAGS) clean

install: package
	sudo installer -pkg TorchGenerator.pkg -target /

uninstall:
	rm -rf "$(FRAMEWORKS_FOLDER)/TorchGeneratorFramework.framework"
	rm -f "$(BINARIES_FOLDER)/torch"

installables: clean bootstrap
	$(BUILD_TOOL) $(XCODEFLAGS) install

	mkdir -p "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"
	mv -f "$(TORCHGENERATOR_FRAMEWORK_BUNDLE)" "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)/TorchGeneratorFramework.framework"
	mv -f "$(TORCHGENERATOR_EXECUTABLE)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/torch"
	rm -rf "$(BUILT_BUNDLE)"

prefix_install: installables
	mkdir -p "$(FRAMEWORKS_FOLDER)" "$(BINARIES_FOLDER)"
	cp -Rf "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)/TorchGeneratorFramework.framework" "$(FRAMEWORKS_FOLDER)"
	cp -f "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/torch" "$(BINARIES_FOLDER)/"

package: installables
	pkgbuild \
		--component-plist "$(COMPONENTS_PLIST)" \
		--identifier "org.brightify.TorchGenerator" \
		--install-location "/" \
		--root "$(TEMPORARY_FOLDER)" \
		--version "$(VERSION_STRING)" \
		"$(OUTPUT_PACKAGE)"

#archive:
#	carthage build --no-skip-current --platform mac
#	carthage archive TorchGeneratorFramework
#
#release: package archive
