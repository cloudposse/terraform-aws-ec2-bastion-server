variable "namespace" {
  default     = "global"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  default     = "default"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  default     = "bastion"
  description = "The Name of the application or solution  (e.g. `bastion` or `portal`)"
}

variable "zone_id" {
  default     = ""
  description = "Route53 DNS Zone id"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Elastic cache instance type"
}

variable "ami" {
  default     = "ami-efd0428f"
  description = "the AMI to use"
}

variable "vpc_id" {
  default     = ""
  description = "VPC ID"
}

variable "subnets" {
  type        = "list"
  default     = []
  description = "AWS subnet ids"
}

variable "user_data" {
  type        = "list"
  default     = []
  description = "User data scripts content"
}

variable "key_name" {
  default     = ""
  description = "Key name"
}

variable "ssh_user" {
  default     = "ubuntu"
  description = "User that used to execute backup cron"
}

variable "security_groups" {
  type        = "list"
  description = "AWS security group ids"
}

variable "user_data_file" {
  default     = "user_data.sh"
  description = "User data file"
}
