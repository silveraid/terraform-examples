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

# create a new 100GB SSD volume
resource "aws_ebs_volume" "opt_volume" {
  availability_zone = "${aws_instance.test_instance.availability_zone}"
  size              = "100"
  type              = "gp2"

  tags = {
    Name = "opt-test-instance"
  }
}

# create an EC2 instance
resource "aws_instance" "test_instance" {
  ami           = "${data.aws_ami.centos_linux.id}"
  instance_type = "t2.micro"

  # configuring type, size of the root device
  root_block_device = {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    "${aws_security_group.ssh_ingress.id}",
  ]

  user_data = "${file("files/mount_opt.sh")}"

  tags = {
    Name = "test-instance"
  }
}

# attached the newly created volume
resource "aws_volume_attachment" "opt_volume_attach" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.opt_volume.id}"
  instance_id = "${aws_instance.test_instance.id}"
}

output "public_ip" {
  value = "${aws_instance.test_instance.public_ip}"
}
