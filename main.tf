locals {
  create_instance_profile = module.this.enabled && try(length(var.instance_profile), 0) == 0
  instance_profile        = local.create_instance_profile ? join("", aws_iam_instance_profile.default.*.name) : var.instance_profile
  eip_enabled             = var.associate_public_ip_address && var.assign_eip_address && module.this.enabled
  security_group_enabled  = module.this.enabled && var.security_group_enabled
  public_dns              = local.eip_enabled ? local.public_dns_rendered : join("", aws_instance.default.*.public_dns)
  public_dns_rendered = local.eip_enabled ? format("ec2-%s.%s.amazonaws.com",
    replace(join("", aws_eip.default.*.public_ip), ".", "-"),
    data.aws_region.default.name == "us-east-1" ? "compute-1" : format("%s.compute", data.aws_region.default.name)
  ) : null
  user_data_templated = templatefile("${path.module}/${var.user_data_template}", {
    user_data   = join("\n", var.user_data)
    ssm_enabled = var.ssm_enabled
    ssh_user    = var.ssh_user
  })
}

data "aws_region" "default" {}

data "aws_ami" "default" {
  count = module.this.enabled && var.ami == null ? 1 : 0

  most_recent = "true"

  dynamic "filter" {
    for_each = var.ami_filter
    content {
      name   = filter.key
      values = filter.value
    }
  }

  owners = var.ami_owners
}

module "security_group" {
  source  = "cloudposse/security-group/aws"
  version = "0.3.3"

  use_name_prefix = var.security_group_use_name_prefix
  rules           = var.security_group_rules
  description     = var.security_group_description
  vpc_id          = var.vpc_id

  enabled = local.security_group_enabled
  context = module.this.context
}

data "aws_route53_zone" "domain" {
  count   = module.this.enabled && try(length(var.zone_id), 0) > 0 ? 1 : 0
  zone_id = var.zone_id
}

resource "aws_instance" "default" {
  #bridgecrew:skip=BC_AWS_PUBLIC_12: Skipping `EC2 Should Not Have Public IPs` check. NAT instance requires public IP.
  #bridgecrew:skip=BC_AWS_GENERAL_31: Skipping `Ensure Instance Metadata Service Version 1 is not enabled` check until BridgeCrew support condition evaluation. See https://github.com/bridgecrewio/checkov/issues/793
  count                       = module.this.enabled ? 1 : 0
  ami                         = coalesce(var.ami, join("", data.aws_ami.default.*.id))
  instance_type               = var.instance_type
  user_data                   = length(var.user_data_base64) > 0 ? var.user_data_base64 : local.user_data_templated
  vpc_security_group_ids      = compact(concat(module.security_group.*.id, var.security_groups))
  iam_instance_profile        = local.instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.key_name
  subnet_id                   = var.subnets[0]
  monitoring                  = var.monitoring
  disable_api_termination     = var.disable_api_termination

  metadata_options {
    http_endpoint               = (var.metadata_http_endpoint_enabled) ? "enabled" : "disabled"
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    http_tokens                 = (var.metadata_http_tokens_required) ? "required" : "optional"
  }

  root_block_device {
    encrypted   = var.root_block_device_encrypted
    volume_size = var.root_block_device_volume_size
  }

  # Optional block; skipped if var.ebs_block_device_volume_size is zero
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device_volume_size > 0 ? [1] : []

    content {
      encrypted             = var.ebs_block_device_encrypted
      volume_size           = var.ebs_block_device_volume_size
      delete_on_termination = var.ebs_delete_on_termination
      device_name           = var.ebs_device_name
      tags                  = module.this.tags
    }
  }

  tags = module.this.tags
}

resource "aws_eip" "default" {
  count    = local.eip_enabled ? 1 : 0
  instance = join("", aws_instance.default.*.id)
  vpc      = true
  tags     = module.this.tags
}

module "dns" {
  source   = "cloudposse/route53-cluster-hostname/aws"
  version  = "0.12.2"
  enabled  = module.this.enabled && try(length(var.zone_id), 0) > 0 ? true : false
  zone_id  = var.zone_id
  ttl      = 60
  records  = var.associate_public_ip_address ? tolist([local.public_dns]) : tolist([join("", aws_instance.default.*.private_dns)])
  context  = module.this.context
  dns_name = local.host_name
}
