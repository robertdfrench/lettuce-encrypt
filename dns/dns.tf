resource "aws_eip" "ip" {
  tags = {
    Name = "lettuce"
  }
}

data "aws_route53_zone" "parent" {
  name = format("%s.", var.parent_zone)
}

variable "parent_zone" {}

resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.parent.id
  name    = "lettuce"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.ip.public_ip]
}
