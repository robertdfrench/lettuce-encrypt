SHELL=bash

install: init
	terraform apply -auto-approve

init: .terraform/initialized
	$(info + Terraform Initialized)

.terraform/initialized: providers.tf
	terraform init
	@touch $@

clean:
	terraform destroy -auto-approve
