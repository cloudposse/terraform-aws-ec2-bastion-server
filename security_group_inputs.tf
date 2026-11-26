# security-group-variables Version: 3
##

variable "create_security_group" {
  type        = bool
  description = "Set `true` to create and configure a new security group. If false, `associated_security_group_ids` must be provided."
  default     = true
}

locals {
  create_security_group = module.this.enabled && (var.security_group_enabled == null ? var.create_security_group : var.security_group_enabled)
}

variable "associated_security_group_ids" {
  type        = list(string)
  description = <<-EOT
    A list of IDs of Security Groups to associate the created resource with, in addition to the created security group.
    These security groups will not be modified and, if `create_security_group` is `false`, must have rules providing the desired access.
    EOT
  default     = []
}

locals {
  associated_security_group_ids = concat(var.security_groups, var.associated_security_group_ids)
}

variable "security_group_name" {
  type        = list(string)
  description = <<-EOT
    The name to assign to the created security group. Must be unique within the VPC.
    If not provided, will be derived from the `null-label.context` passed in.
    If `create_before_destroy` is true, will be used as a name prefix.
    EOT
  default     = []
  validation {
    condition     = length(var.security_group_name) < 2
    error_message = "Only 1 security group name can be provided."
  }
}

variable "security_group_create_before_destroy" {
  type        = bool
  description = <<-EOT
    Set `true` to enable terraform `create_before_destroy` behavior on the created security group.
    We only recommend setting this `false` if you are importing an existing security group
    that you do not want replaced and therefore need full control over its name.
    Note that changing this value will always cause the security group to be replaced.
    EOT
  default     = true
}

locals {
  security_group_create_before_destroy = var.security_group_use_name_prefix == null ? var.security_group_create_before_destroy : var.security_group_use_name_prefix
}

variable "preserve_security_group_id" {
  type        = bool
  description = <<-EOT
    When `false` and `security_group_create_before_destroy` is `true`, changes to security group rules
    cause a new security group to be created with the new rules, and the existing security group is then
    replaced with the new one, eliminating any service interruption.
    When `true` or when changing the value (from `false` to `true` or from `true` to `false`),
    existing security group rules will be deleted before new ones are created, resulting in a service interruption,
    but preserving the security group itself.
    **NOTE:** Setting this to `true` does not guarantee the security group will never be replaced,
    it only keeps changes to the security group rules from triggering a replacement.
    See the [terraform-aws-security-group README](https://github.com/cloudposse/terraform-aws-security-group) for further discussion.
    EOT
  default     = false
}

variable "security_group_create_timeout" {
  type        = string
  description = "How long to wait for the security group to be created."
  default     = "10m"
}

variable "security_group_delete_timeout" {
  type        = string
  description = <<-EOT
    How long to retry on `DependencyViolation` errors during security group deletion from
    lingering ENIs left by certain AWS services such as Elastic Load Balancing.
    EOT
  default     = "15m"
}

variable "allow_all_egress" {
  type        = bool
  description = <<-EOT
    If `true`, the created security group will allow egress on all ports and protocols to all IP addresses.
    If this is false and no egress rules are otherwise specified, then no egress will be allowed.
    Defaults to `true` unless the deprecated `security_group_rules` contains an egress rule, as its default does,
    in which case defaults to `false`.
    EOT
  default     = null
}

variable "additional_security_group_rules" {
  type        = list(any)
  description = <<-EOT
    A list of Security Group rule objects to add to the created security group, in addition to the ones
    this module normally creates. (To suppress the module's rules, set `create_security_group` to false
    and supply your own security group(s) via `associated_security_group_ids`.)
    The keys and values of the objects are fully compatible with the `aws_security_group_rule` resource, except
    for `security_group_id` which will be ignored, and the optional "key" which, if provided, must be unique and known at "plan" time.
    For more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
    and https://github.com/cloudposse/terraform-aws-security-group.
    EOT
  default     = []
}
