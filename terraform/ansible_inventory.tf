# Hand-off between Terraform and Ansible: write an inventory file containing
# the new server's IP, SSH key and the S3 bucket name. Ansible reads it as-is.
resource "local_file" "ansible_inventory" {
  filename        = "${local.repo_root}/ansible/inventory/hosts.ini"
  file_permission = "0644"

  content = templatefile("${path.module}/templates/hosts.ini.tftpl", {
    host_name        = "${local.name_prefix}-web"
    public_ip        = aws_instance.web.public_ip
    ssh_user         = "ubuntu"
    private_key_path = local.private_key_path
    s3_bucket_name   = aws_s3_bucket.this.bucket
    aws_region       = var.aws_region
    environment      = var.environment
  })
}
