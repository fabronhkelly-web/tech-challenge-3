output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance."
  value       = aws_instance.web.public_dns
}

output "website_url" {
  description = "URL of the Hello World page (live once Ansible has run)."
  value       = "http://${aws_instance.web.public_ip}"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket."
  value       = aws_s3_bucket.this.bucket
}

output "iam_role_name" {
  description = "IAM role attached to the instance."
  value       = aws_iam_role.ec2.name
}

output "security_group_id" {
  description = "ID of the web security group."
  value       = aws_security_group.web.id
}

output "ssh_allowed_cidr" {
  description = "CIDR currently allowed to SSH in."
  value       = local.ssh_allowed_cidr
}

output "ssh_command" {
  description = "Command to SSH into the instance."
  value       = "ssh -i ${local.private_key_path} ubuntu@${aws_instance.web.public_ip}"
}
