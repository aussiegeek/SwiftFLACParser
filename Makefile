.PHONY: all samples

all: test build

samples:
	cd samples && make

test: samples
	swift test

build:
	swift build