SHELL=bash
assertEnv=@if [ -z $${$(strip $1)+x} ]; then >&2 echo "You need to define \$$$(strip $1)"; exit 1; fi

check: install
	$(call assertEnv, PARENT_ZONE)
	ssh root@lettuce.$(PARENT_ZONE) hostname | grep lettuce.$(PARENT_ZONE)
	curl https://lettuce.$(PARENT_ZONE)/

install: image dns init
	$(call assertEnv, PARENT_ZONE)
	terraform apply -auto-approve -var 'parent_zone=$(PARENT_ZONE)'

init: .terraform/initialized
	$(info + Terraform Initialized)

.terraform/initialized: providers.tf
	terraform init
	@touch $@

.PHONY: image
image:
	$(MAKE) -C image install

.PHONY: dns
dns:
	$(MAKE) -C dns install

clean:
	$(call assertEnv, PARENT_ZONE)
	terraform destroy -auto-approve -var 'parent_zone=$(PARENT_ZONE)'