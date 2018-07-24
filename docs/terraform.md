
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami | the AMI to use | string | `ami-efd0428f` | no |
| instance_type | Elastic cache instance type | string | `t2.micro` | no |
| key_name | Key name | string | `` | no |
| name | The Name of the application or solution  (e.g. `bastion` or `portal`) | string | `bastion` | no |
| namespace | Namespace (e.g. `cp` or `cloudposse`) | string | `global` | no |
| security_groups | AWS security group ids | list | - | yes |
| ssh_user | Default SSH user for this AMI. e.g. `ec2user` for Amazon Linux and `ubuntu` for Ubuntu systems | string | - | yes |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | `default` | no |
| subnets | AWS subnet ids | list | `<list>` | no |
| user_data | User data scripts content | list | `<list>` | no |
| user_data_file | User data file | string | `user_data.sh` | no |
| vpc_id | VPC ID | string | `` | no |
| zone_id | Route53 DNS Zone id | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | Instance id |
| private_ip | Private IP of instance |
| public_ip | Public IP of instance (or EIP) |
| role | Name of AWS IAM Role associated with the instance |
| security_group_id | Security group id |
| ssh_user | SSH user |

