REPO := amancevice/$(shell basename $$PWD)

ENDPOINT = http://$$(REPO=$(REPO) docker-compose port lambda 8080)/2015-03-31/functions/function/invocations

all: validate

clean:
	rm -rf .terraform

clobber: clean
	rm -rf .terraform.lock.hcl

validate: | .terraform
	terraform fmt -check
	AWS_REGION=us-east-1 terraform validate

.PHONY: all clean clobber up validate

.terraform:
	terraform init
