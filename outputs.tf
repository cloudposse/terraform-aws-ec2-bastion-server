# -----------------------------------------------------------------------------
# OUTPUTS: TF-MOD-AWS-EC2-BASTION-SERVER
# -----------------------------------------------------------------------------

output "instance_id" {
  value       = join("", aws_instance.default.*.id)
  description = "Instance ID"
}

output "ssh_user" {
  value       = var.ssh_user
  description = "SSH user"
}

output "security_group_ids" {
  description = "IDs on the AWS Security Groups associated with the instance"
  value = compact(
    concat(
      formatlist("%s", module.security_group.id),
      var.security_groups
    )
  )
}

output "role" {
  value       = join("", aws_iam_role.default.*.name)
  description = "Name of AWS IAM Role associated with the instance"
}

output "public_ip" {
  value       = concat(aws_eip.default.*.public_ip, aws_instance.default.*.public_ip, [""])[0]
  description = "Public IP of the instance (or EIP)"
}

output "private_ip" {
  value       = join("", aws_instance.default.*.private_ip)
  description = "Private IP of the instance"
}

output "private_dns" {
  description = "Private DNS of instance"
  value       = join("", aws_instance.default.*.private_dns)
}

output "public_dns" {
  description = "Public DNS of instance (or DNS of EIP)"
  value       = local.public_dns
}

output "hostname" {
  value       = module.dns.hostname
  description = "DNS hostname"
}

output "id" {
  description = "Disambiguated ID of the instance"
  value       = join("", aws_instance.default.*.id)
}

output "arn" {
  description = "ARN of the instance"
  value       = join("", aws_instance.default.*.arn)
}

output "name" {
  description = "Instance name"
  value       = module.this.id
}

output "security_group_id" {
  value       = module.security_group.id
  description = "Bastion host Security Group ID"
}

output "security_group_arn" {
  value       = module.security_group.arn
  description = "Bastion host Security Group ARN"
}

output "security_group_name" {
  value       = module.security_group.name
  description = "Bastion host Security Group name"
}
