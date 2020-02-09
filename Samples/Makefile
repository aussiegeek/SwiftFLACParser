TEST_FILE_METADTA := $(wildcard *.txt)
TEST_FILES := $(patsubst %.txt, %.flac, ${TEST_FILE_METADTA})

.PHONY: all
all: ${TEST_FILES}

%.flac: %.txt blank.flac
	cp blank.flac $@
	metaflac $@ --import-tags-from=$<

blank.wav:
	ffmpeg -f lavfi -i anullsrc=r=44100:cl=mono -t 1 -q:a 9 blank.wav

blank.flac: blank.wav
	flac -f blank.wav
