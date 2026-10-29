# Latest official Ubuntu 24.04 LTS AMI published by Canonical.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Use the account's default VPC so the project works out of the box.
data "aws_vpc" "default" {
  default = true
}

# Public IP of the machine running Terraform, used to lock SSH down to you only.
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  ssh_allowed_cidr = (
    var.ssh_allowed_cidr != ""
    ? var.ssh_allowed_cidr
    : "${chomp(data.http.my_ip.response_body)}/32"
  )

  # Generated files live outside the terraform/ folder so Ansible can find them.
  repo_root        = abspath("${path.module}/..")
  ssh_key_dir      = var.ssh_key_dir != "" ? var.ssh_key_dir : "${local.repo_root}/.keys"
  private_key_path = "${local.ssh_key_dir}/${local.name_prefix}.pem"
}
