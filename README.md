# 🥬 Lettuce Encrypt 🔐
*Zero-touch deployment of EC2 + TLS*

*Lettuce Encrypt* is a pattern for deploying EC2 web servers that can obtain
their own TLS certificates from [Let's Encrypt](https://letsencrypt.org). You'll
need an AWS account and at least one domain already registered in [Route53][2].

### What it does
Simply `make provision PARENT_ZONE=x` where x is a domain that you already have
registered in Route53. Assuming you have valid AWS credentials, Lettuce Encrypt
will do the following:

1. Reserve a static IP address and assign it to a new subdomain ([dns](dns/))
1. Create a new AMI ([image](image/))
1. Create a small storage volume to hold your Let's Encrypt certs ([storage](storage/))
1. Deploy an EC2 instance which mounts this volume and uses the reserved IP
1. Provision this instance, obtaining or renewing Let's Encrypt certs as needed

### Caveats
This pattern assumes that the instance is not part of a cluster (i.e. that you
will be obtaining a certificate for a domain that points to a *single* EC2
instance) and thus is better suited for deploying infrastructure appliances than
for large-scale websites.

### Legal
Because this pattern automates the creation of a Let's Encrypt account, you are
obligated to agree to the [Let's Encrypt Subscriber Agreement][1].

[1]: https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf
[2]: https://aws.amazon.com/route53/
