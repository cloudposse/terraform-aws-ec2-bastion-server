resource "aws_iam_instance_profile" "default" {
  count = module.this.enabled ? 1 : 0
  name  = module.this.id
  role  = aws_iam_role.default[0].name
}

resource "aws_iam_role" "default" {
  count = module.this.enabled ? 1 : 0
  name  = module.this.id
  path  = "/"
  tags  = module.this.tags

  assume_role_policy = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_security_group" "default" {
  count       = module.this.enabled ? 1 : 0
  name        = module.this.id
  vpc_id      = var.vpc_id
  description = "Bastion host security group"

  tags = module.this.tags

  # Optional block; skipped if var.allowed_cidr_blocks is empty
  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = var.allowed_cidr_blocks
      description = "Allow SSH ingress traffic from trusted CIDR Blocks"
    }
  }

  # Optional block; skipped if var.ingress_security_groups is empty
  dynamic "ingress" {
    for_each = length(var.ingress_security_groups) > 0 ? [1] : []
    content {
      from_port       = 0
      to_port         = 0
      protocol        = -1
      security_groups = var.ingress_security_groups
      description     = "Allow ALL ingress traffic from trusted Security Groups"
    }
  }

  # Optional block; skipped unless var.egress_allowed is set to true
  dynamic "egress" {
    for_each = var.egress_allowed ? [1] : []
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow ALL egress traffic"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "domain" {
  count   = module.this.enabled && var.zone_id != "" ? 1 : 0
  zone_id = var.zone_id
}

data "template_file" "user_data" {
  count    = module.this.enabled ? 1 : 0
  template = file("${path.module}/user_data.sh")

  vars = {
    user_data       = join("\n", var.user_data)
    welcome_message = module.this.stage
    hostname        = "${module.this.name}.${join("", data.aws_route53_zone.domain.*.name)}"
    search_domains  = join("", data.aws_route53_zone.domain.*.name)
    ssh_user        = var.ssh_user
  }
}

resource "aws_instance" "default" {
  #bridgecrew:skip=BC_AWS_PUBLIC_12: Skipping `EC2 Should Not Have Public IPs` check. NAT instance requires public IP.
  #bridgecrew:skip=BC_AWS_GENERAL_31: Skipping `Ensure Instance Metadata Service Version 1 is not enabled` check until BridgeCrew support condition evaluation. See https://github.com/bridgecrewio/checkov/issues/793
  count         = module.this.enabled ? 1 : 0
  ami           = var.ami
  instance_type = var.instance_type

  user_data = data.template_file.user_data[0].rendered

  vpc_security_group_ids = compact(concat(aws_security_group.default.*.id, var.security_groups))

  iam_instance_profile        = aws_iam_instance_profile.default[0].name
  associate_public_ip_address = var.associate_public_ip_address

  key_name = var.key_name

  subnet_id = var.subnets[0]

  tags = module.this.tags

  metadata_options {
    http_endpoint               = (var.metadata_http_endpoint_enabled) ? "enabled" : "disabled"
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    http_tokens                 = (var.metadata_http_tokens_required) ? "required" : "optional"
  }

  root_block_device {
    encrypted   = var.root_block_device_encrypted
    volume_size = var.root_block_device_volume_size
  }
}

module "dns" {
  source   = "cloudposse/route53-cluster-hostname/aws"
  version  = "0.12.0"
  enabled  = module.this.enabled && var.zone_id != "" ? true : false
  zone_id  = var.zone_id
  ttl      = 60
  records  = var.associate_public_ip_address ? aws_instance.default.*.public_dns : aws_instance.default.*.private_dns
  context  = module.this.context
  dns_name = var.host_name
}
