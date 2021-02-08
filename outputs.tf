output "instance_id" {
  value       = join("", aws_instance.default.*.id)
  description = "Instance ID"
}

output "ssh_user" {
  value       = var.ssh_user
  description = "SSH user"
}

output "security_group_id" {
  value       = module.default_sg.id
  description = "Security group ID"
}

output "security_group_arn" {
  value       = module.default_sg.arn
  description = "Security Group ARN"
}

output "security_group_name" {
  value       = module.default_sg.name
  description = "Security Group name"
}

output "role" {
  value       = join("", aws_iam_role.default.*.name)
  description = "Name of AWS IAM Role associated with the instance"
}

output "public_ip" {
  value       = join("", aws_instance.default.*.public_ip)
  description = "Public IP of the instance (or EIP)"
}

output "private_ip" {
  value       = join("", aws_instance.default.*.private_ip)
  description = "Private IP of the instance"
}

output "hostname" {
  value       = module.dns.hostname
  description = "DNS hostname"
}

