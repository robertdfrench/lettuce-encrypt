SHELL=bash
assertEnv=@if [ -z $${$(strip $1)+x} ]; then >&2 echo "You need to define \$$$(strip $1)"; exit 1; fi

check: install
	$(call assertEnv, PARENT_ZONE)
	ssh -o StrictHostKeyChecking=false root@lettuce.$(PARENT_ZONE) hostname \
		| grep lettuce.$(PARENT_ZONE)
	curl https://lettuce.$(PARENT_ZONE)/

provision: install
	scp -r -o StrictHostKeyChecking=false provisions root@lettuce.$(PARENT_ZONE):/tmp
	ssh -o StrictHostKeyChecking=false root@lettuce.$(PARENT_ZONE) \
		/usr/gnu/bin/make -C /tmp/provisions DOMAIN=lettuce.$(PARENT_ZONE)

install: image dns storage init
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

.PHONY: storage
storage:
	$(MAKE) -C storage install

clean:
	$(call assertEnv, PARENT_ZONE)
	terraform destroy -auto-approve -var 'parent_zone=$(PARENT_ZONE)'
