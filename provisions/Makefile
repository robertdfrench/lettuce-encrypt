include lib.mk

all: letsencrypt
	$(call done, $@)

## letsencrypt
.PHONY: letsencrypt
letsencrypt: hostname dehydrated letsencrypt.crontab
	if [ ! -e /etc/dehydrated/certs/`hostname`/privkey.pem ]; then \
		/usr/bin/dehydrated --cron --domain `hostname`; \
	fi
	if ! (crontab -l | grep "dehydrated"); then \
		crontab  <(crontab -l && cat letsencrypt.crontab); \
	fi
	$(call done, $@)


## dehydrated
.PHONY: dehydrated
dehydrated: nginx zpool /etc/dehydrated/accounts /etc/dehydrated/config
	$(call done, $@)

/etc/dehydrated/accounts:
	$(MAKE) /etc/dehydrated/config
	/usr/bin/dehydrated --register --accept-terms

/etc/dehydrated/config: /etc/dehydrated dehydrated.config
	cp dehydrated.config $@
	chown nginx $@

/etc/dehydrated: /persistent/mounted
	mkdir -p /persistent$@
	chown nginx /persistent$@
	ln -s /persistent$@ $@


## zpool
.PHONY: zpool
zpool: /persistent/mounted
	$(call done, $@)

/persistent/mounted:
	zpool create -m /persistent persistent c1t5d0 || zpool import -f persistent
	@touch $@

.PHONY: zpool.down
zpool.down:
	zpool export persistent
	@echo "~zpool"


## hostname
.PHONY: hostname
hostname:
	$(call assertEnv, DOMAIN)
	hostname -s $(DOMAIN)
	$(call done, $@)


## nginx
.PHONY: nginx
nginx: /opt/ooce/nginx-1.16/html/.well-known/acme-challenge /etc/opt/ooce/nginx-1.16/nginx.conf
	svcadm enable svc:/network/http
	$(call done, $@)

/etc/opt/ooce/nginx-1.16/nginx.conf: nginx.conf
	cp $< $@

/opt/ooce/nginx-1.16/html/.well-known/acme-challenge: /opt/ooce/nginx-1.16/html/.well-known
	mkdir -p $@
	chown nginx $@

/opt/ooce/nginx-1.16/html/.well-known:
	mkdir -p $@
	chown nginx $@
