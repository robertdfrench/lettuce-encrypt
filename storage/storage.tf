// Create a 1GB volume in the us-east-1 region in the availability zone "A"
// We will also need to create our webserver instance in this same availability
// zone in order for this volume to be attached.
resource "aws_ebs_volume" "storage" {
  availability_zone = "us-east-1a"
  size              = 1

  // Tag everything "lettuce" so we can reference them higher up the stack
  tags = {
    Name = "lettuce"
  }
}
