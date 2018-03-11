resource "aws_security_group" "ssh_ingress" {
  name        = "ssh_ingress"
  description = "SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
