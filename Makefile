VERSION = $(shell godzil show-version)
CURRENT_REVISION = $(shell git rev-parse --short HEAD)
BUILD_LDFLAGS = "-s -w -X github.com/Songmu/godzil.revision=$(CURRENT_REVISION)"
ifdef update
  u=-u
endif

export GO111MODULE=on

deps:
	go get ${u} -d

test-deps:
	go get ${u} -d -t

devel-deps: deps
	GO111MODULE=off go get ${u} \
	  golang.org/x/lint/golint            \
	  github.com/mattn/goveralls          \
	  github.com/Songmu/godzil/cmd/godzil \
	  github.com/Songmu/goxz/cmd/goxz     \
	  github.com/tcnksm/ghr

test: test-deps
	go test

lint: devel-deps
	go vet
	golint -set_exit_status

cover: devel-deps
	goveralls

build: deps
	go build -ldflags=$(BUILD_LDFLAGS) ./cmd/godzil

bump: devel-deps
	godzil release

crossbuild:
	goxz -pv=v$(VERSION) -build-ldflags=$(BUILD_LDFLAGS) \
      -os=linux,darwin -d=./dist/v$(VERSION) ./cmd/*

upload:
	ghr v$(VERSION) dist/v$(VERSION)

release: bump crossbuild upload

.PHONY: test deps test-deps devel-deps lint cover build bump crossbuild upload release
