variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used for every resource."
  type        = string
  default     = "tech-challenge-3"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,30}$", var.project_name))
    error_message = "project_name must be 3-30 characters of lowercase letters, numbers and hyphens (it is used in the S3 bucket name)."
  }
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type. t3.micro is Free Tier eligible in most regions."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Size of the EC2 root volume in GiB."
  type        = number
  default     = 8
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH into the instance (e.g. 203.0.113.10/32). Leave empty to auto-detect your current public IP."
  type        = string
  default     = ""

  validation {
    condition     = var.ssh_allowed_cidr == "" || can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "ssh_allowed_cidr must be empty or a valid CIDR block, e.g. 203.0.113.10/32."
  }
}

variable "ssh_key_dir" {
  description = "Directory where the generated SSH private key is written. Empty means <repo>/.keys. The Docker toolbox sets this to /keys so the key keeps strict permissions on Windows."
  type        = string
  default     = ""
}

variable "s3_force_destroy" {
  description = "Allow `terraform destroy` to delete the S3 bucket even if it still contains objects."
  type        = bool
  default     = true
}
