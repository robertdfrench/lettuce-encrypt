variable "parent_zone" {}

locals {
  name     = "lettuce"
  hostname = format("lettuce.%s", var.parent_zone)
}

resource "aws_instance" "lettuce" {
  ami               = data.aws_ami.image.id
  instance_type     = "t2.micro"
  key_name          = aws_key_pair.key_pair.key_name
  security_groups   = [aws_security_group.security_group.name]
  availability_zone = "us-east-1a"
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

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.lettuce.id
  volume_id   = data.aws_ebs_volume.storage.id

  connection {
    host = aws_eip_association.eip_assoc.public_ip
  }

  provisioner "remote-exec" {
    inline = ["zpool create -m /persistent persistent c1t5d0"]
  }

  provisioner "remote-exec" {
    when   = "destroy"
    inline = ["zpool destroy -f persistent"]
  }
}

data "aws_ebs_volume" "storage" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["lettuce"]
  }
}
