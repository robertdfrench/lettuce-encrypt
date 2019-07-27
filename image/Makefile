include lib.mk

install: packed.state
	@echo + Packer image complete

packed.state: packer.json provision.sh
	packer build packer.json
	@touch $@

clean:
	$(warning Not yet implemented, clean the images up yourself!)
