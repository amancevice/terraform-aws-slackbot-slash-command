runtime := nodejs10.x
name    := slackbot-slash-command
build   := $(shell git describe --tags --always)

image   := amancevice/$(name)
iidfile := .docker/$(build)
digest   = $(shell cat $(iidfile))

$(name)-$(build).zip: main.tf outputs.tf variables.tf package.zip | node_modules
	zip $@ $?

package.zip: index.js package-lock.json
	docker run --rm $(digest) cat $@ > $@

package-lock.json: package.json | $(iidfile)
	docker run --rm $(digest) cat $@ > $@

node_modules: | $(iidfile)
	docker run --rm $(digest) tar czO $@ | tar xzf -

$(iidfile): package.json | .docker
	docker build \
	--build-arg RUNTIME=$(runtime) \
	--iidfile $@ \
	--tag $(image):$(build) .

.docker:
	mkdir -p $@

.PHONY: shell clean

shell: | $(iidfile)
	docker run --rm -it $(digest) /bin/bash

clean:
	docker image rm -f $(image) $(shell sed G .docker/*)
	rm -rf .docker $(name)*.zip node_modules
