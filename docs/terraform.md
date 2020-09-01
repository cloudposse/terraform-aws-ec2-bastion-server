<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |
| aws | ~> 2.55 |
| null | ~> 2.1 |
| template | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.55 |
| template | ~> 2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_cidr\_blocks | A list of CIDR blocks allowed to connect | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| ami | AMI to use | `string` | `"ami-efd0428f"` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| egress\_allowed | Allow all egress traffic from instance | `bool` | `false` | no |
| enabled | When disabled, module will not create any resources | `bool` | `true` | no |
| ingress\_security\_groups | AWS security group IDs allowed ingress to instance | `list(string)` | `[]` | no |
| instance\_type | Elastic cache instance type | `string` | `"t2.micro"` | no |
| key\_name | Key name | `string` | `""` | no |
| name | Name  (e.g. `app` or `bastion`) | `string` | n/a | yes |
| namespace | Namespace (e.g. `eg` or `cp`) | `string` | n/a | yes |
| security\_groups | AWS security group IDs associated with instance | `list(string)` | `[]` | no |
| ssh\_user | Default SSH user for this AMI. e.g. `ec2user` for Amazon Linux and `ubuntu` for Ubuntu systems | `string` | n/a | yes |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | `string` | n/a | yes |
| subnets | AWS subnet IDs | `list(string)` | n/a | yes |
| tags | Additional tags (e.g. map('BusinessUnit`,`XYZ`)` | `map(string)` | `{}` | no |
| user\_data | User data content | `list(string)` | `[]` | no |
| vpc\_id | VPC ID | `string` | n/a | yes |
| zone\_id | Route53 DNS Zone ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| hostname | DNS hostname |
| instance\_id | Instance ID |
| private\_ip | Private IP of the instance |
| public\_ip | Public IP of the instance (or EIP) |
| role | Name of AWS IAM Role associated with the instance |
| security\_group\_id | Security group ID |
| ssh\_user | SSH user |

<!-- markdownlint-restore -->
