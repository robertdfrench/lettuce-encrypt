# 🥬 Lettuce Encrypt 🔐
*Zero-touch deployment of EC2 + TLS*

*Lettuce Encrypt* is a pattern for deploying EC2 web servers that can obtain
their own TLS certificates from [Let's Encrypt](https://letsencrypt.org). This
pattern assumes that the instance is not part of a cluster (i.e. that you will
be obtaining a certificate for a domain that points to a *single* EC2 instance)
and thus is better suited for deploying infrastructure appliances than for large
scal websites.

### Legal
Because this pattern automates the creation of a Let's Encrypt account, you are
obligated to agree to the [Let's Encrypt Subscriber Agreement][1].

[1]: https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf
