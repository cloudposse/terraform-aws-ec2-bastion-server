resource "aws_iam_instance_profile" "default" {
  count = module.this.enabled ? 1 : 0
  name  = module.this.id
  role  = aws_iam_role.default[0].name
}

resource "aws_iam_role" "default" {
  count = module.this.enabled ? 1 : 0
  name  = module.this.id
  path  = "/"

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
  description = "Bastion security group (only SSH inbound access is allowed)"

  tags = module.this.tags

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    description = "Allow ingress to groups listed in var.allowed_cidr_blocks"

    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    description     = "Allow ingress to groups listed in var.ingress_security"
    security_groups = var.ingress_security_groups
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
  source  = "cloudposse/route53-cluster-hostname/aws"
  version = "0.7.0"
  enabled = module.this.enabled && var.zone_id != "" ? true : false
  name    = module.this.name
  zone_id = var.zone_id
  ttl     = 60
  records = var.associate_public_ip_address ? aws_instance.default.*.public_dns : aws_instance.default.*.private_dns
}
