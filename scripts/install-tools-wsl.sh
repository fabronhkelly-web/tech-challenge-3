#!/usr/bin/env bash
# Installs Terraform, Ansible, the AWS CLI and helpers on Ubuntu / WSL Ubuntu.
# Safe to re-run: tools that are already installed are skipped.
set -euo pipefail

sudo apt-get update -y
sudo apt-get install -y curl unzip gnupg software-properties-common python3 python3-pip pipx make

if ! command -v terraform >/dev/null 2>&1; then
  echo "==> Installing Terraform"
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
  sudo apt-get update -y && sudo apt-get install -y terraform
fi

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "==> Installing Ansible"
  pipx install --include-deps ansible
  pipx inject ansible ansible-lint --include-apps || true
  pipx ensurepath
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "==> Installing AWS CLI v2"
  tmp="$(mktemp -d)"
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$tmp/awscliv2.zip"
  unzip -q "$tmp/awscliv2.zip" -d "$tmp"
  sudo "$tmp/aws/install"
  rm -rf "$tmp"
fi

echo
echo "Installed versions:"
terraform version | head -1
(ansible --version 2>/dev/null || "$HOME/.local/bin/ansible" --version) | head -1
aws --version
echo
echo "Open a new terminal (or run 'source ~/.bashrc') so PATH changes take effect."
