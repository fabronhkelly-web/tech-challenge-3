# Generate an SSH key pair so nobody has to create one by hand.
# The public half is registered with AWS; the private half is written to
# .keys/ (git-ignored) for Ansible to use.
resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "this" {
  key_name   = "${local.name_prefix}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh.private_key_openssh
  filename        = local.private_key_path
  file_permission = "0600"
}
