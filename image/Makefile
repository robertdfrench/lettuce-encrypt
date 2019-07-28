include lib.mk

install: packed.state
	$(call done, Packer)

packed.state: packer.json provision.sh
	packer build packer.json
	@touch $@

clean: ## Remove any images that contain the word "lettuce" in the name
	aws ec2 describe-images --owners self \
		|  jq -r '.Images[] | select(.Name | contains("lettuce")) | .ImageId' \
		| xargs -n1 aws ec2 deregister-image --image-id
