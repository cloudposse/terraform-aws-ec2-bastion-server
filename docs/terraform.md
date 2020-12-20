<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.26 |
| aws | >= 2.55 |
| null | >= 2.1 |
| template | >= 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.55 |
| template | >= 2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tag\_map | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| allowed\_cidr\_blocks | A list of CIDR blocks allowed to connect | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| ami | AMI to use | `string` | `"ami-084ef34fdfdd7384c"` | no |
| associate\_public\_ip\_address | Whether to associate a public IP to the instance. | `bool` | `true` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| context | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | <pre>object({<br>    enabled             = bool<br>    namespace           = string<br>    environment         = string<br>    stage               = string<br>    name                = string<br>    delimiter           = string<br>    attributes          = list(string)<br>    tags                = map(string)<br>    additional_tag_map  = map(string)<br>    regex_replace_chars = string<br>    label_order         = list(string)<br>    id_length_limit     = number<br>  })</pre> | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_order": [],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| environment | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| id\_length\_limit | Limit `id` to this many characters.<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| ingress\_security\_groups | AWS security group IDs allowed ingress to instance | `list(string)` | `[]` | no |
| instance\_type | Bastion instance type | `string` | `"t2.micro"` | no |
| key\_name | Key name | `string` | `""` | no |
| label\_order | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| metadata\_http\_endpoint\_enabled | Whether the metadata service is available | `bool` | `true` | no |
| metadata\_http\_put\_response\_hop\_limit | The desired HTTP PUT response hop limit (between 1 and 64) for instance metadata requests. | `number` | `1` | no |
| metadata\_http\_tokens\_required | Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2. | `bool` | `false` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| regex\_replace\_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| root\_block\_device\_encrypted | Whether to encrypt the root block device | `bool` | `false` | no |
| root\_block\_device\_volume\_size | The volume size (in GiB) to provision for the root block device. It cannot be smaller than the AMI it refers to. | `number` | `8` | no |
| security\_groups | AWS security group IDs associated with instance | `list(string)` | `[]` | no |
| ssh\_user | Default SSH user for this AMI. e.g. `ec2user` for Amazon Linux and `ubuntu` for Ubuntu systems | `string` | n/a | yes |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| subnets | AWS subnet IDs | `list(string)` | n/a | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
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
