include lib.mk

check: install ## Can we access the webserver over https?
	$(call assertEnv, PARENT_ZONE)
	curl https://lettuce.$(PARENT_ZONE)/

install: pubkey image dns storage init ## Deploy and provision the webserver
	$(call assertEnv, PARENT_ZONE)
	terraform apply -auto-approve -var 'parent_zone=$(PARENT_ZONE)'
	scp -pr -o StrictHostKeyChecking=false -o ConnectTimeout=300 \
		provisions root@lettuce.$(PARENT_ZONE):/tmp
	ssh -o StrictHostKeyChecking=false root@lettuce.$(PARENT_ZONE) \
		/usr/gnu/bin/make -C /tmp/provisions DOMAIN=lettuce.$(PARENT_ZONE)

init: .terraform/initialized ## Download terraform plugins
	$(info + Terraform Initialized)

.terraform/initialized: providers.tf
	terraform init
	@touch $@

.PHONY: image
image: ## Build a custom AMI for the webserver
	$(MAKE) -C image install

.PHONY: dns
dns: ## Reserve an IP4 address and register an A record under the PARENT_ZONE
	$(call assertEnv, PARENT_ZONE)
	$(MAKE) -C dns install PARENT_ZONE=$(PARENT_ZONE)

.PHONY: storage
storage: ## Reseve an EBS volume where the Let's Encrypt certificates can live
	$(MAKE) -C storage install

clean: ## Destroy the webserver (not the eip, image, or storage)
	$(call assertEnv, PARENT_ZONE)
	terraform destroy -auto-approve -var 'parent_zone=$(PARENT_ZONE)'

clean_all: clean ## Destroy *everything*
	$(call assertEnv, PARENT_ZONE)
	$(MAKE) -C storage clean
	$(MAKE) -C dns clean PARENT_ZONE=$(PARENT_ZONE)
	$(MAKE) -C image clean
	rm -rf .terraform

.PHONY: pubkey
pubkey: $(HOME)/.ssh/id_rsa.pub
	$(info +pubkey)

$(HOME)/.ssh/id_rsa.pub:
	$(error Lettuce Encrypt assumes you have a valid RSA-formatted SSH keypair. Please use ssh-keygen to make one)
