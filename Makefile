name    := slackbot-slash-command
runtime := nodejs10.x
build   := $(shell git describe --tags --always)
digest   = $(shell cat .docker/$(build)$(1))

.PHONY: all clean shell@% test

all: package-lock.json package.zip

.docker:
	mkdir -p $@

.docker/$(build)@test: .docker/$(build)@build
.docker/$(build)@%: | .docker
	docker build \
	--build-arg RUNTIME=$(runtime) \
	--iidfile $@ \
	--tag amancevice/$(name):$(build)-$* \
	--target $* .

package-lock.json package.zip: .docker/$(build)@build
	docker run --rm -w /var/task/ $(call digest,@build) cat $@ > $@

clean:
	-docker image rm -f $(shell awk {print} .docker/*)
	-rm -rf .docker

shell@%: .docker/$(build)@%
	docker run --rm -it $(call digest,@$*) /bin/bash

test: all .docker/$(build)@test
