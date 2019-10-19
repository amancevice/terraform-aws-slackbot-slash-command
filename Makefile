runtime := nodejs10.x
stages  := build test
build   := $(shell git describe --tags --always)
shells  := $(foreach stage,$(stages),shell@$(stage))

terraform_version := latest

.PHONY: all clean $(stages) $(shells)

all: package-lock.json package.zip test

.docker:
	mkdir -p $@

.docker/$(build)@test: .docker/$(build)@build
.docker/$(build)@%: | .docker
	docker build \
	--build-arg RUNTIME=$(runtime) \
	--build-arg TERRAFORM=$(terraform_version) \
	--iidfile $@ \
	--tag amancevice/slackbot-slash-command:$(build)-$* \
	--target $* .

package-lock.json package.zip: .docker/$(build)@build
	docker run --rm $(shell cat $<) cat $@ > $@

clean:
	-docker image rm -f $(shell awk {print} .docker/*)
	-rm -rf .docker

$(stages): %: .docker/$(build)@%

$(shells): shell@%: .docker/$(build)@%
	docker run --rm -it $(shell cat $<) /bin/bash
