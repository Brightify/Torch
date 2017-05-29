.PHONY : clean superclean build test

default: clean build

clean:
	swift package clean

superclean:
	rm -rf .build

build:
	swift build

test: build
	#cd Tests && cucumber
	echo "No tests for Generator"
