provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.7.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.16.0"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false
}

resource "aws_key_pair" "test" {
  key_name   = format("%s-test-key", var.name)
  public_key = var.ssh_public_key
}

module "ec2_bastion" {
  source = "../../"

  enabled = var.enabled

  ami           = var.ami
  instance_type = var.instance_type

  name       = var.name
  namespace  = var.namespace
  stage      = var.stage
  tags       = var.tags
  attributes = var.attributes

  security_groups = [module.vpc.vpc_default_security_group_id]
  subnets         = module.subnets.public_subnet_ids
  ssh_user        = var.ssh_user
  key_name        = aws_key_pair.test.key_name

  vpc_id = module.vpc.vpc_id
}