variable "security_groups" {
  type        = list(string)
  default     = []
  description = <<-EOT
    DEPRECATED: Use `associated_security_group_ids` instead.
    Historical description: A list of Security Group IDs to associate with bastion host.
    EOT
}

variable "security_group_enabled" {
  type        = bool
  default     = null
  description = <<-EOT
    DEPRECATED: Use `create_security_group` instead.
    Historical description: Whether to create default Security Group for bastion host.
    Historical default: `true`
    EOT
}

variable "security_group_use_name_prefix" {
  type        = bool
  default     = null
  description = <<-EOT
    DEPRECATED: Use `security_group_create_before_destroy` instead.
    Historical description: Whether to create a default Security Group with unique name beginning with the normalized prefix.
    Historical default: `false`
    EOT
}

variable "security_group_rules" {
  type = list(any)
  default = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    },
    {
      type        = "ingress"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all inbound to SSH"
    }
  ]
  description = <<-EOT
    DEPRECATED: Use `additional_security_group_rules` and `allow_all_egress` instead.
    The default creates the rules this module has always created: SSH from anywhere and all outbound traffic.
    Set this to `[]` to manage all rules with `additional_security_group_rules` and `allow_all_egress`.
    Historical description: A list of maps of Security Group rules.
    The values of map is fully complated with `aws_security_group_rule` resource.
    To get more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule .
    EOT
}

locals {
  legacy_security_group_rules = var.security_group_rules == null ? [] : var.security_group_rules

  # If var.allow_all_egress is null, allow all egress unless the deprecated
  # var.security_group_rules provides its own egress rules, as the default does.
  allow_all_egress = var.allow_all_egress == null ? length([for r in local.legacy_security_group_rules : r if r.type == "egress"]) == 0 : var.allow_all_egress
}
