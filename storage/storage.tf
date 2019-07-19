resource "aws_ebs_volume" "storage" {
  availability_zone = "us-east-1a"
  size              = 1

  tags = {
    Name = "lettuce"
  }
}
