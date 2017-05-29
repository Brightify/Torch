#!/usr/bin/env bash
rm -rf Build
mkdir Build
xcodebuild -project 'TorchGenerator.xcodeproj' -scheme 'TorchGenerator' CONFIGURATION_BUILD_DIR=$(pwd)/Build clean build
ln -s ../Tests/SourceFiles Build/SourceFiles
cd Tests
cucumber
