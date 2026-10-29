resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Allow HTTP from anywhere and SSH from the operator only"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${local.name_prefix}-web-sg"
  }
}

# HTTP open to the world so the Hello World page is reachable.
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# SSH restricted to the IP running Terraform/Ansible (or ssh_allowed_cidr).
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH from operator"
  cidr_ipv4         = local.ssh_allowed_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# Outbound open so the instance can reach apt mirrors and S3.
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  description       = "All outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
