variable "namespace" {
  default = "global"
}

variable "stage" {
  default = "default"
}

variable "name" {
  default = "bastion"
}

variable "zone_id" {
  default = ""
}

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

variable "user_data" {
  type    = "list"
  default = []
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