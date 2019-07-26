#!/usr/bin/bash -ex
pkg set-publisher -g https://pkg.omniosce.org/r151030/extra/ extra.omnios
pkg install nginx-116 gnu-make
curl --silent \
	https://raw.githubusercontent.com/lukas2511/dehydrated/master/dehydrated \
	> /usr/bin/dehydrated \
	&& chmod +x /usr/bin/dehydrated
