# terraform-aws-ec2-bastion-server [![Build Status](https://travis-ci.org/cloudposse/terraform-aws-ec2-bastion-server.svg?branch=master)](https://travis-ci.org/cloudposse/terraform-aws-ec2-bastion-server) [![Latest Release](https://img.shields.io/github/release/cloudposse/terraform-aws-ec2-bastion-server.svg)](https://github.com/cloudposse/terraform-aws-ec2-bastion-server/releases/latest) [![Slack Community](https://slack.cloudposse.com/badge.svg)](https://slack.cloudposse.com)


Terraform module to define a generic Bastion host with parameterized `user_data`


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed_cidr_blocks | A list of CIDR blocks allowed to connect | list | `<list>` | no |
| ami | AMI to use | string | `ami-efd0428f` | no |
| attributes | Additional attributes (e.g. `1`) | list | `<list>` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| instance_type | Elastic cache instance type | string | `t2.micro` | no |
| key_name | Key name | string | `` | no |
| name | Name  (e.g. `app` or `bastion`) | string | - | yes |
| namespace | Namespace (e.g. `eg` or `cp`) | string | - | yes |
| security_groups | AWS security group IDs | list | - | yes |
| ssh_user | Default SSH user for this AMI. e.g. `ec2user` for Amazon Linux and `ubuntu` for Ubuntu systems | string | - | yes |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | - | yes |
| subnets | AWS subnet IDs | list | - | yes |
| tags | Additional tags (e.g. map('BusinessUnit`,`XYZ`) | map | `<map>` | no |
| user_data | User data content | list | `<list>` | no |
| user_data_file | User data file | string | `user_data.sh` | no |
| vpc_id | VPC ID | string | - | yes |
| zone_id | Route53 DNS Zone ID | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | Instance ID |
| private_ip | Private IP of the instance |
| public_ip | Public IP of the instance (or EIP) |
| role | Name of AWS IAM Role associated with the instance |
| security_group_id | Security group ID |
| ssh_user | SSH user |




## Related Projects

Check out these related projects.

- [bastion](https://github.com/cloudposse/bastion) - 🔒Secure Bastion implemented as Docker Container running Alpine Linux with Google Authenticator & DUO MFA support
- [terraform-aws-ec2-instance](https://github.com/cloudposse/terraform-aws-ec2-instance) - Terraform module for providing a general EC2 instance provisioned by Ansible
- [terraform-aws-ec2-ami-backup](https://github.com/cloudposse/terraform-aws-ec2-ami-backup) - Terraform module for automatic & scheduled AMI creation

### Contributors

|  [![Erik Osterman][osterman_avatar]][osterman_homepage]<br/>[Erik Osterman][osterman_homepage] | [![Andriy Knysh][aknysh_avatar]][aknysh_homepage]<br/>[Andriy Knysh][aknysh_homepage] | [![Igor Rodionov][goruha_avatar]][goruha_homepage]<br/>[Igor Rodionov][goruha_homepage] | [![Bobby Larson][karma0_avatar]][karma0_homepage]<br/>[Bobby Larson][karma0_homepage] |
|---|---|---|---|

  [osterman_homepage]: https://github.com/osterman
  [osterman_avatar]: https://github.com/osterman.png?size=150
  [aknysh_homepage]: https://github.com/aknysh
  [aknysh_avatar]: https://github.com/aknysh.png?size=150
  [goruha_homepage]: https://github.com/goruha
  [goruha_avatar]: https://github.com/goruha.png?size=150
  [karma0_homepage]: https://github.com/karma0
  [karma0_avatar]: https://github.com/karma0.png?size=150


