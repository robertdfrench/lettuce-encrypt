# DNS
This module reserves a static IP for your appliance by using [AWS Elastic IP][1]
and then assigns that IP to a DNS record using [AWS Route 53][2]. Reserving a
static IP allows us to restart the appliance as needed without having to update
DNS each time.

[1]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html
[2]: https://aws.amazon.com/route53/
