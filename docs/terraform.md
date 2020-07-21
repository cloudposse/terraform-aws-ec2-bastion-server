## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_cidr\_blocks | A list of CIDR blocks allowed to connect | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| ami | AMI to use | `string` | `"ami-efd0428f"` | no |
| attributes | Additional attributes (e.g. `1`) | `list` | `[]` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| instance\_type | Elastic cache instance type | `string` | `"t2.micro"` | no |
| key\_name | Key name | `string` | `""` | no |
| name | Name  (e.g. `app` or `bastion`) | `string` | n/a | yes |
| namespace | Namespace (e.g. `eg` or `cp`) | `string` | n/a | yes |
| security\_groups | AWS security group IDs | `list` | n/a | yes |
| ssh\_user | Default SSH user for this AMI. e.g. `ec2user` for Amazon Linux and `ubuntu` for Ubuntu systems | `string` | n/a | yes |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | `string` | n/a | yes |
| subnets | AWS subnet IDs | `list` | n/a | yes |
| tags | Additional tags (e.g. map('BusinessUnit`,`XYZ`)` | `map` | `{}` | no |
| user\_data | User data content | `list` | `[]` | no |
| user\_data\_file | User data file | `string` | `"user_data.sh"` | no |
| vpc\_id | VPC ID | `string` | n/a | yes |
| zone\_id | Route53 DNS Zone ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_id | Instance ID |
| private\_ip | Private IP of the instance |
| public\_ip | Public IP of the instance (or EIP) |
| role | Name of AWS IAM Role associated with the instance |
| security\_group\_id | Security group ID |
| ssh\_user | SSH user |

