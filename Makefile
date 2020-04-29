REPO      := amancevice/slackbot-slash-command
RUNTIME   := nodejs12.x
STAGES    := zip test
TERRAFORM := latest
VERSION   := $(shell git describe --tags --always)

.PHONY: default clean clobber $(STAGES)

default: package-lock.json package.zip test

.docker:
	mkdir -p $@

.docker/zip: index.js package.json
.docker/test: .docker/zip
.docker/%: | .docker
	docker build \
	--build-arg RUNTIME=$(RUNTIME) \
	--build-arg TERRAFORM=$(TERRAFORM) \
	--iidfile $@ \
	--tag $(REPO):$* \
	--target $* \
	.

package-lock.json package.zip: .docker/zip
	docker run --rm --entrypoint cat $$(cat $<) $@ > $@

clean:
	rm -rf .docker

clobber: clean
	docker image ls $(REPO) --quiet | uniq | xargs docker image rm --force

$(STAGES): %: .docker/%
