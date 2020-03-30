output "instance_id" {
  value       = aws_instance.default.*.id
  description = "Instance ID"
}

output "ssh_user" {
  value       = var.ssh_user
  description = "SSH user"
}

output "security_group_id" {
  value       = aws_security_group.default.*.id
  description = "Security group ID"
}

output "role" {
  value       = aws_iam_role.default.*.name
  description = "Name of AWS IAM Role associated with the instance"
}

output "public_ip" {
  value       = aws_instance.default.*.public_ip
  description = "Public IP of the instance (or EIP)"
}

output "private_ip" {
  value       = aws_instance.default.*.private_ip
  description = "Private IP of the instance"
}

output "public_subnet_cidrs" {
  value = module.subnets.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  value = module.subnets.private_subnet_cidrs
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}

output "key_pair_id" {
  value = aws_key_pair.test.key_pair_id
}

output "key_name" {
  value = aws_key_pair.test.key_name
}