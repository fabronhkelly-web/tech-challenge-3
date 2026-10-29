provider "aws" {
  region = var.aws_region

  # Every resource created by this project gets these tags automatically,
  # which makes it easy to find (and clean up) everything in the console.
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
