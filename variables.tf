variable "namespace" {
  description = "Namespace (e.g. `eg` or `cp`)"
  type        = "string"
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  type        = "string"
}

variable "name" {
  description = "Name  (e.g. `app` or `bastion`)"
  type        = "string"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map('BusinessUnit`,`XYZ`)"
}

variable "zone_id" {
  type        = "string"
  default     = ""
  description = "Route53 DNS Zone ID"
}

variable "instance_type" {
  type        = "string"
  default     = "t2.micro"
  description = "Elastic cache instance type"
}

variable "ami" {
  type        = "string"
  default     = "ami-efd0428f"
  description = "AMI to use"
}

variable "vpc_id" {
  type        = "string"
  description = "VPC ID"
}

variable "subnets" {
  type        = "list"
  description = "AWS subnet IDs"
}

variable "user_data" {
  type        = "list"
  default     = []
  description = "User data content"
}

variable "key_name" {
  type        = "string"
  default     = ""
  description = "Key name"
}

variable "ssh_user" {
  type        = "string"
  description = "Default SSH user for this AMI. e.g. `ec2user` for Amazon Linux and `ubuntu` for Ubuntu systems"
}

variable "security_groups" {
  type        = "list"
  description = "AWS security group IDs"
}

variable "allowed_cidr_blocks" {
  type        = "list"
  description = "A list of CIDR blocks allowed to connect"

  default = [
    "0.0.0.0/0",
  ]
}

variable "user_data_file" {
  type        = "string"
  default     = "user_data.sh"
  description = "User data file"
}
