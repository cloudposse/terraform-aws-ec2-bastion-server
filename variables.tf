variable "namespace" {
  default = "global"
}

variable "provider" {}

variable "stage" {
  default = "default"
}

variable "name" {
  default = "bastion"
}

variable "zone_id" {
  default = ""
}

variable "ssm_region" {
  default = ""
}

variable "ssm_app" {
  default = ""
}

variable "github_api_token" {}
variable "github_organization" {}
variable "github_team" {}

variable "db_cluster_name" {}
variable "db_name" {}
variable "db_user" {}
variable "db_password" {}
variable "db_host" {}
variable "db_host_replicas" {}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  default = "ami-efd0428f"
}

variable "vpc_id" {
  default = ""
}

variable "subnets" {
  type    = "list"
  default = []
}

variable "assets_backup_enabled" {
  default = "false"
}

variable "assets_backup_frequency" {
  default = "5 1 * * *"
}

variable "assets_bucket" {
  default = ""
}

variable "additional_user_data_script" {
  default = "date"
}

variable "key_name" {
  default = ""
}

variable "ssh_user" {
  default = "ubuntu"
}

variable "security_groups" {
  type = "list"
}

variable "user_data_file" {
  default = "user_data.sh"
}

variable "efs_host" {
  default = ""
}

variable "backup_bucket" {
  default = ""
}
