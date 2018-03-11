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

data "aws_route53_zone" "zone" {
  name = "example.com."
}

# create an EC2 instance
resource "aws_instance" "instance" {
  count = "${length(var.instances)}"

  ami           = "${data.aws_ami.centos_linux.id}"
  instance_type = "${lookup(var.instances[count.index], "instance_type")}"

  tags = {
    Name = "${lookup(var.instances[count.index], "hostname")}"
  }
}

# create A records for the hosts
resource "aws_route53_record" "dns" {
  count   = "${length(var.instances)}"
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  type    = "A"
  ttl     = "60"
  name    = "${element(aws_instance.instance.*.tags.Name, count.index)}"
  records = ["${element(aws_instance.instance.*.public_ip, count.index)}"]
}
