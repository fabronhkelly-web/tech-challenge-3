#!/usr/bin/env bash
# One-command deployment: provision with Terraform, then configure with Ansible.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for cmd in terraform ansible-playbook aws; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: '$cmd' is not installed. See README > Prerequisites." >&2; exit 1; }
done

echo "==> Checking AWS credentials"
aws sts get-caller-identity --query 'Arn' --output text

echo "==> Terraform: provisioning infrastructure"
cd "$ROOT/terraform"
terraform init -input=false
terraform apply -input=false -auto-approve

URL="$(terraform output -raw website_url)"

echo "==> Ansible: configuring the web server"
cd "$ROOT/ansible"
ansible-playbook site.yml

echo "==> Verifying from this machine"
for i in $(seq 1 10); do
  if curl -fsS "$URL" | grep -q "Hello, World!"; then
    echo "SUCCESS: $URL is serving 'Hello, World!'"
    exit 0
  fi
  echo "   waiting for $URL ($i/10)..."
  sleep 3
done

echo "ERROR: $URL did not return 'Hello, World!'" >&2
exit 1
