#!/usr/bin/bash -ex
curl --silent \
	https://raw.githubusercontent.com/lukas2511/dehydrated/master/dehydrated \
	> /usr/bin/dehydrated \
	&& chmod +x /usr/bin/dehydrated
