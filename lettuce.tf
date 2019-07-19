variable "parent_zone" {}

locals {
  name     = "lettuce"
  hostname = format("lettuce.%s", var.parent_zone)
}

resource "aws_instance" "lettuce" {
  ami             = data.aws_ami.image.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.key_pair.key_name
  security_groups = [aws_security_group.security_group.name]
  tags = {
    Name = local.name
  }
}

data "aws_ami" "image" {
  most_recent = true
  owners      = ["self"]
  name_regex  = "^lettuce-*"
}

resource "aws_key_pair" "key_pair" {
  key_name   = local.name
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}

resource "aws_security_group" "security_group" {
  name        = local.name
  description = format("SSH, HTTP, and HTTPS for %s", local.name)

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.name
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.lettuce.id
  allocation_id = data.aws_eip.ip.id

  connection {
    host = local.hostname
  }

  provisioner "remote-exec" {
    inline = [format("hostname -s %s", local.hostname)]
  }
}

data "aws_eip" "ip" {
  tags = {
    Name = "lettuce"
  }
}
