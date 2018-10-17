
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

