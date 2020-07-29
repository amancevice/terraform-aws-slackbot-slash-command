REPO    := amancevice/$(shell basename $$PWD)
RUNTIME := nodejs12.x

.PHONY: clean clobber validate zip

validate: package.zip | .terraform
	terraform fmt -check
	terraform validate

package.zip: package.iid package-lock.json
	docker run --rm --entrypoint cat $$(cat $<) $@ > $@

package-lock.json: package.iid
	docker run --rm --entrypoint cat $$(cat $<) $@ > $@

package.iid: index.js package.json Dockerfile
	docker build --build-arg RUNTIME=$(RUNTIME) --iidfile $@ --tag $(REPO) .

.terraform:
	terraform init

clean:
	rm -rf package.iid

clobber: clean
	docker image ls --quiet $(REPO) | uniq | xargs docker image rm --force

zip: package.zip
