#!/usr/bin/env bash
# Tear down everything Terraform created (EC2, S3 bucket and contents, IAM, SG, key pair).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT/terraform"
terraform destroy -input=false -auto-approve

rm -f "$ROOT/ansible/inventory/hosts.ini"
echo "All resources destroyed."
