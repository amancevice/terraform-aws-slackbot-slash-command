# Project
runtime   := nodejs10.x
name      := slackbot-slash-command
release   := $(shell git describe --tags)
build     := $(name)-$(release)
buildfile := build/$(build).build
distfile  := dist/$(build).zip

# Docker Build
image := amancevice/$(name)
digest = $(shell cat $(buildfile))

$(distfile): package.zip | dist
	docker run --rm $(digest) cat /var/task/package.zip > $@

package.zip: package-lock.json
	docker run --rm $(digest) cat /var/task/$@ > $@

package-lock.json: package.json | $(buildfile)
	docker run --rm $(digest) cat /var/task/$@ > $@

$(buildfile): index.js | build
	docker build \
	--build-arg RUNTIME=$(runtime) \
	--iidfile $@ \
	--tag $(image):$(release) .

%:
	mkdir -p $@

.PHONY: clean

clean:
	docker image rm -f $(image) $(shell sed G build/*)
	rm -rf build dist
