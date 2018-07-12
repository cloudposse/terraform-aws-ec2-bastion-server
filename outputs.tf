output "instance_id" {
  value       = "${aws_instance.default.id}"
  description = "Instance id"
}

output "ssh_user" {
  value       = "${var.ssh_user}"
  description = "SSH user"
}

output "security_group_id" {
  value       = "${aws_security_group.default.id}"
  description = "Security group id"
}

output "role" {
  value       = "${aws_iam_role.default.name}"
  description = "Name of AWS IAM Role associated with the instance"
}

output "public_ip" {
  value       = "${aws_instance.default.public_ip}"
  description = "Public IP of instance (or EIP)"
}

output "private_ip" {
  value       = "${aws_instance.default.private_ip}"
  description = "Private IP of instance"
}
