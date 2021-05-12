locals {
  instance_profile_count = module.this.enabled ? (length(var.instance_profile) > 0 ? 0 : 1) : 0
  instance_profile       = local.instance_profile_count == 0 ? var.instance_profile : join("", aws_iam_instance_profile.default.*.name)
  eip_enabled            = var.associate_public_ip_address && var.assign_eip_address && module.this.enabled
  public_dns             = local.eip_enabled ? local.public_dns_rendered : join("", aws_instance.default.*.public_dns)
  public_dns_rendered = local.eip_enabled ? format("ec2-%s.%s.amazonaws.com",
    replace(join("", aws_eip.default.*.public_ip), ".", "-"),
    data.aws_region.default.name == "us-east-1" ? "compute-1" : format("%s.compute", data.aws_region.default.name)
  ) : null
}

data "aws_region" "default" {}

data "aws_ami" "default" {
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
  version = "0.2.0"

  description = "Bastion host security group"
  rules       = var.security_group_rules
  vpc_id      = var.vpc_id

  enabled = module.this.enabled
  context = module.this.context
}

data "aws_route53_zone" "domain" {
  count   = module.this.enabled && var.zone_id != "" ? 1 : 0
  zone_id = var.zone_id
}

data "template_file" "user_data" {
  count    = module.this.enabled ? 1 : 0
  template = file("${path.module}/${var.user_data_template}")

  vars = {
    user_data   = join("\n", var.user_data)
    ssm_enabled = var.ssm_enabled
    ssh_user    = var.ssh_user
  }
}

resource "aws_instance" "default" {
  #bridgecrew:skip=BC_AWS_PUBLIC_12: Skipping `EC2 Should Not Have Public IPs` check. NAT instance requires public IP.
  #bridgecrew:skip=BC_AWS_GENERAL_31: Skipping `Ensure Instance Metadata Service Version 1 is not enabled` check until BridgeCrew support condition evaluation. See https://github.com/bridgecrewio/checkov/issues/793
  count                       = module.this.enabled ? 1 : 0
  ami                         = data.aws_ami.default.id
  instance_type               = var.instance_type
  user_data                   = length(var.user_data_base64) > 0 ? var.user_data_base64 : data.template_file.user_data[0].rendered
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
    }
  }

  tags = module.this.tags
}

resource "aws_eip" "default" {
  count             = local.eip_enabled ? 1 : 0
  network_interface = join("", aws_instance.default.*.primary_network_interface_id)
  vpc               = true
  tags              = module.this.tags
}

module "dns" {
  source   = "cloudposse/route53-cluster-hostname/aws"
  version  = "0.12.0"
  enabled  = module.this.enabled && var.zone_id != "" ? true : false
  zone_id  = var.zone_id
  ttl      = 60
  records  = var.associate_public_ip_address ? tolist([local.public_dns]) : tolist([join("", aws_instance.default.*.private_dns)])
  context  = module.this.context
  dns_name = var.host_name
}
