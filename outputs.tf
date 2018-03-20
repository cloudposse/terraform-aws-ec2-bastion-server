output "instance_id" {
  value = "${aws_instance.default.id}"
}

output "ssh_user" {
  value = "${var.ssh_user}"
}

output "security_group_id" {
  value = "${aws_security_group.default.id}"
}

output "role" {
  value = "${aws_iam_role.default.name}"
}

output "public_ip" {
  value = "${aws_instance.default.public_ip}"
}

output "private_ip" {
  value = "${aws_instance.default.private_ip}"
}
