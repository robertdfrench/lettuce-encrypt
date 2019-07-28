include lib.mk

install: init ## Deploy our new storage volume
	terraform apply -auto-approve

init: .terraform/initialized
	$(call done, Terraform initialized)

.terraform/initialized: providers.tf
	terraform init
	@touch $@

clean: ## Tear down the storage volume
	terraform destroy -auto-approve
