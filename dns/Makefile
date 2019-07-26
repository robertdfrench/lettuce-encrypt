include lib.mk

check: install
	$(call assertEnv, PARENT_ZONE)
	dig +short lettuce.$(PARENT_ZONE) | grep -v "*"

install: init
	$(call assertEnv, PARENT_ZONE)
	terraform apply -auto-approve -var 'parent_zone=$(PARENT_ZONE)'

init: .terraform/initialized
	$(info + Terraform Initialized)

.terraform/initialized: providers.tf
	terraform init
	@touch $@

clean:
	$(call assertEnv, PARENT_ZONE)
	terraform destroy -auto-approve -var 'parent_zone=$(PARENT_ZONE)'
