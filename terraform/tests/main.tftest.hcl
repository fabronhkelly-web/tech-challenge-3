# Offline tests: every provider is mocked, so these run without AWS
# credentials and create nothing. Run with: terraform test
# (Terraform >= 1.7 or OpenTofu >= 1.8)

mock_provider "aws" {
  mock_data "aws_ami" {
    defaults = {
      id = "ami-0123456789abcdef0"
    }
  }

  mock_data "aws_vpc" {
    defaults = {
      id = "vpc-0123456789abcdef0"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_resource "aws_s3_bucket" {
    defaults = {
      arn = "arn:aws:s3:::tech-challenge-3-dev-test"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::123456789012:policy/tech-challenge-3-dev-s3-access"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/tech-challenge-3-dev-ec2-role"
    }
  }

  mock_resource "aws_instance" {
    defaults = {
      public_ip = "198.51.100.20"
    }
  }
}

mock_provider "http" {
  mock_data "http" {
    defaults = {
      response_body = "198.51.100.7\n"
    }
  }
}

mock_provider "local" {}
mock_provider "tls" {}

run "ssh_locked_to_detected_ip" {
  command = plan

  assert {
    condition     = aws_vpc_security_group_ingress_rule.ssh.cidr_ipv4 == "198.51.100.7/32"
    error_message = "SSH should be restricted to the auto-detected public IP."
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.http.from_port == 80 && aws_vpc_security_group_ingress_rule.http.cidr_ipv4 == "0.0.0.0/0"
    error_message = "HTTP (80) should be open to the world."
  }
}

run "ssh_uses_explicit_cidr_when_set" {
  command = plan

  variables {
    ssh_allowed_cidr = "203.0.113.10/32"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.ssh.cidr_ipv4 == "203.0.113.10/32"
    error_message = "SSH should use ssh_allowed_cidr when provided."
  }
}

run "rejects_invalid_cidr" {
  command = plan

  variables {
    ssh_allowed_cidr = "not-a-cidr"
  }

  expect_failures = [var.ssh_allowed_cidr]
}

run "instance_and_bucket_are_hardened" {
  command = plan

  assert {
    condition     = aws_instance.web.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 must be required."
  }

  assert {
    condition     = aws_instance.web.root_block_device[0].encrypted
    error_message = "Root volume must be encrypted."
  }

  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.this.block_public_acls,
      aws_s3_bucket_public_access_block.this.block_public_policy,
      aws_s3_bucket_public_access_block.this.ignore_public_acls,
      aws_s3_bucket_public_access_block.this.restrict_public_buckets,
    ])
    error_message = "All S3 public access must be blocked."
  }

  assert {
    condition     = aws_instance.web.iam_instance_profile == "tech-challenge-3-dev-ec2-profile"
    error_message = "The instance must use the project's instance profile."
  }
}

run "inventory_handed_to_ansible" {
  command = apply

  assert {
    condition     = strcontains(local_file.ansible_inventory.content, "ansible_host=198.51.100.20")
    error_message = "Inventory must contain the instance public IP."
  }

  assert {
    condition     = strcontains(local_file.ansible_inventory.content, "s3_bucket_name=${aws_s3_bucket.this.bucket}")
    error_message = "Inventory must pass the bucket name to Ansible."
  }

  assert {
    condition     = output.website_url == "http://198.51.100.20"
    error_message = "website_url output should point at the instance."
  }
}
