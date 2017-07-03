# Define composite variables for resources
module "label" {
  source    = "git::https://github.com/cloudposse/tf_label.git"
  namespace = "${var.namespace}"
  name      = "${var.name}"
  stage     = "${var.stage}"
}

resource "aws_iam_instance_profile" "default" {
  name = "${module.label.id}"
  role = "${aws_iam_role.default.name}"
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

resource "aws_iam_role" "default" {
  name = "${module.label.id}"
  path = "/"

  assume_role_policy = "${data.aws_iam_policy_document.default.json}"
}

## IAM Role Policy that allows access to S3
resource "aws_iam_policy" "s3" {
  name = "${module.label.id}-s3"

  lifecycle {
    create_before_destroy = true
  }

  policy = "${data.aws_iam_policy_document.s3.json}"
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${var.backup_bucket}",
      "arn:aws:s3:::${var.backup_bucket}/*",
      "arn:aws:s3:::${lower(format("%v-%v*",    var.namespace, var.stage))}",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = "${aws_iam_role.default.name}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}

data "aws_iam_policy_document" "s3-assets" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${var.assets_bucket}",
      "arn:aws:s3:::${var.assets_bucket}/*",
    ]
  }
}

resource "aws_iam_policy" "s3-assets" {
  count = "${length(var.assets_bucket) > 0 ? 1 : 0}"
  name  = "${module.label.id}-s3-assets"

  lifecycle {
    create_before_destroy = true
  }

  policy = "${data.aws_iam_policy_document.s3-assets.json}"
}

resource "aws_iam_role_policy_attachment" "s3-assets" {
  count      = "${length(var.assets_bucket) > 0 ? 1 : 0}"
  role       = "${aws_iam_role.default.name}"
  policy_arn = "${aws_iam_policy.s3-assets.arn}"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = "${aws_iam_role.default.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  depends_on = ["aws_iam_role.default"]
}

resource "aws_iam_role_policy_attachment" "instances" {
  role       = "${aws_iam_role.default.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  depends_on = ["aws_iam_role.default"]
}

resource "aws_security_group" "default" {
  name        = "${module.label.id}"
  vpc_id      = "${var.vpc_id}"
  description = "Bastion security group (only SSH inbound access is allowed)"

  tags {
    Name      = "${module.label.id}"
    Namespace = "${var.namespace}"
    Stage     = "${var.stage}"
  }

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = ["${var.security_groups}"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "domain" {
  zone_id = "${var.zone_id}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/${var.user_data_file}")}"

  vars {
    ssh_user            = "${var.ssh_user}"
    github_api_token    = "${var.github_api_token}"
    github_organization = "${var.github_organization}"
    github_team         = "${var.github_team}"
    db_cluster_name     = "${var.db_cluster_name}"
    db_name             = "${var.db_name}"
    db_user             = "${var.db_user}"
    db_password         = "${var.db_password}"
    db_host             = "${var.db_host}"
    db_host_replicas    = "${var.db_host_replicas}"
    namespace           = "${var.namespace}"
    name                = "${var.name}"
    stage               = "${var.stage}"
    region              = "${var.ssm_region}"
    app                 = "${var.ssm_app}"

    hostname                    = "${var.name}.${data.aws_route53_zone.domain.name}"
    search_domains              = "${data.aws_route53_zone.domain.name}"
    assets_backup_enabled       = "${var.assets_backup_enabled}"
    assets_backup_frequency     = "${var.assets_backup_frequency}"
    assets_bucket               = "${var.assets_bucket}"
    additional_user_data_script = "${var.additional_user_data_script}"
    efs_host                    = "${var.efs_host}"
  }
}

resource "aws_instance" "default" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"

  user_data = "${data.template_file.user_data.rendered}"

  vpc_security_group_ids = [
    "${compact(concat(list(aws_security_group.default.id), var.security_groups))}",
  ]

  iam_instance_profile        = "${aws_iam_instance_profile.default.name}"
  associate_public_ip_address = "true"

  key_name = "${var.key_name}"

  subnet_id = "${var.subnets[0]}"

  tags {
    Name      = "${module.label.id}"
    Namespace = "${var.namespace}"
    Stage     = "${var.stage}"
  }
}

module "dns" {
  source    = "git::https://github.com/cloudposse/tf_hostname.git"
  namespace = "${var.namespace}"
  name      = "${var.name}"
  stage     = "${var.stage}"
  zone_id   = "${var.zone_id}"
  ttl       = 60
  records   = ["${aws_instance.default.public_dns}"]
}
