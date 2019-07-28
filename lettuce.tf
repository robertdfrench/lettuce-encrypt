// Route53 zone under which we are deploying this host. For example if
// PARENT_ZONE=example.org, then the host will be lettuce.example.org.
variable "parent_zone" {}

locals {
  name     = "lettuce" // Tag everything "lettuce" for easy cleanup
  hostname = format("lettuce.%s", var.parent_zone)
}

resource "aws_instance" "lettuce" {
  ami               = data.aws_ami.image.id
  instance_type     = "t2.micro"
  key_name          = aws_key_pair.key_pair.key_name
  security_groups   = [aws_security_group.security_group.name]
  availability_zone = "us-east-1a" // Same AZ as our EBS volume
  tags = {
    Name = local.name
  }
}

// Find the latest AMI whose name starts with "lettuce"
data "aws_ami" "image" {
  most_recent = true
  owners      = ["self"]
  name_regex  = "^lettuce-*"
}

// Create a keypair based on your RSA public key (assuming you have one)
resource "aws_key_pair" "key_pair" {
  key_name   = local.name
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}

// Create a security group that allows SSH, HTTP, and HTTPS traffic
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

// Associate our static IP with the newly created EC2 instance. When a new
// instance is created, it will be issued a default public IP. Associating this
// EIP overrides the dynamic IP provided by Amazon, so that our DNS records will
// not need to be updated every time the host reboots.
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.lettuce.id
  allocation_id = data.aws_eip.ip.id
}

data "aws_eip" "ip" {
  tags = {
    Name = "lettuce"
  }
}

// Attach our persistent storage volume to the new instance. By design, our
// Let's Encrypt certificates are stored here, so once it is attached (and
// mounted by the provisioning step) we will be able to access those certs.
resource "aws_volume_attachment" "ebs_att" {
  device_name  = "/dev/sdf"
  instance_id  = aws_instance.lettuce.id
  volume_id    = data.aws_ebs_volume.storage.id
  force_detach = true
}

data "aws_ebs_volume" "storage" {
  most_recent = true
  filter {
    name   = "tag:Name"
    values = ["lettuce"]
  }
}
