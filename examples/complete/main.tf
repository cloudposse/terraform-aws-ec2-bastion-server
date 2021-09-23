provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "0.25.0"

  cidr_block = "172.16.0.0/16"

  context = module.this.context
}

module "subnets" {
  source               = "cloudposse/dynamic-subnets/aws"
  version              = "0.39.3"
  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context = module.this.context
}

module "aws_key_pair" {
  source              = "cloudposse/key-pair/aws"
  version             = "0.18.0"
  attributes          = ["ssh", "key"]
  ssh_public_key_path = var.ssh_key_path
  generate_ssh_key    = var.generate_ssh_key

  context = module.this.context
}

module "ec2_bastion" {
  source = "../../"

  enabled = module.this.enabled

  instance_type               = var.instance_type
  security_groups             = compact(concat([module.vpc.vpc_default_security_group_id], var.security_groups))
  subnets                     = module.subnets.public_subnet_ids
  key_name                    = module.aws_key_pair.key_name
  user_data                   = var.user_data
  vpc_id                      = module.vpc.vpc_id
  associate_public_ip_address = var.associate_public_ip_address

  context = module.this.context
}
