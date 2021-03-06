# set region to Canada Central
provider "aws" {
  region = "ca-central-1"
}

# find the latest centos release what I like to use
data "aws_ami" "centos_linux" {
  most_recent = true

  filter = {
    name = "name"

    values = [
      "CentOS Linux 7 x86_64 HVM EBS *",
    ]
  }

  filter = {
    name = "owner-alias"

    values = [
      "aws-marketplace",
    ]
  }
}

# create an EC2 instance
resource "aws_instance" "test-instance" {
  ami           = "${data.aws_ami.centos_linux.id}"
  instance_type = "t2.micro"

  # configuring type, size of the root device
  root_block_device = {
    volume_type           = "gp2"
    volume_size           = "40"
    delete_on_termination = true
  }

  tags = {
    Name = "test-instance"
  }
}
