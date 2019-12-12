module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

resource "aws_iam_instance_profile" "default" {
  name = module.label.id
  role = aws_iam_role.default.name
}

resource "aws_iam_role" "default" {
  name = module.label.id
  path = "/"

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
  name        = module.label.id
  vpc_id      = var.vpc_id
  description = "Bastion security group (only SSH inbound access is allowed)"

  tags = module.label.tags

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = var.security_groups
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "domain" {
  count   = var.zone_id != "" ? 1 : 0
  zone_id = var.zone_id
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    user_data       = join("\n", var.user_data)
    welcome_message = var.stage
    hostname        = "${var.name}.${join("", data.aws_route53_zone.domain.*.name)}"
    search_domains  = join("", data.aws_route53_zone.domain.*.name)
    ssh_user        = var.ssh_user
  }
}

resource "aws_instance" "default" {
  ami           = var.ami
  instance_type = var.instance_type

  user_data = data.template_file.user_data.rendered

  vpc_security_group_ids = compact(concat(list(aws_security_group.default.id), var.security_groups))

  iam_instance_profile        = aws_iam_instance_profile.default.name
  associate_public_ip_address = "true"

  key_name = var.key_name

  subnet_id = var.subnets[0]

  tags = module.label.tags
}

module "dns" {
  enabled   = var.zone_id != "" ? true : false
  source    = "git::https://github.com/ITSvitCo/terraform-aws-route53-cluster-hostname.git?ref=tags/0.3.1"
  namespace = var.namespace
  name      = var.name
  stage     = var.stage
  zone_id   = var.zone_id
  ttl       = 60
  records   = [aws_instance.default.public_dns]
}
