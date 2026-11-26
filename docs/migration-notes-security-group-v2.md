# Migration Notes: security-group v2

Versions of this module after 0.31.2 use
[terraform-aws-security-group](https://github.com/cloudposse/terraform-aws-security-group)
v2.2.0 instead of v0.3.3, and require Terraform 1.0.0 or later.

## Input changes

These inputs are deprecated. They still work, and each one feeds the input that replaces it.

| Deprecated input                 | Replacement                                           |
|----------------------------------|-------------------------------------------------------|
| `security_groups`                | `associated_security_group_ids`                       |
| `security_group_enabled`         | `create_security_group`                               |
| `security_group_use_name_prefix` | `security_group_create_before_destroy`                |
| `security_group_rules`           | `additional_security_group_rules`, `allow_all_egress` |

The default `security_group_rules` still creates the same 2 rules as before: SSH from
anywhere and all outbound traffic. To stop using it, set `security_group_rules = []`, then
add your rules with `additional_security_group_rules`. `allow_all_egress` then defaults
to `true`, which allows all outbound IPv4 and IPv6 traffic.

## Security group replacement

By default, upgrading replaces the bastion's security group. See
[Avoiding Service Interruptions](https://github.com/cloudposse/terraform-aws-security-group#avoiding-service-interruptions)
in the security-group module for what this affects.

## Keeping the existing security group

To keep the existing security group, follow these steps. They don't work if you set
`security_group_use_name_prefix = true`, because the old group's name was generated.

1. Update the module version and add `security_group_create_before_destroy = false`.
   This keeps the security group's name and its Terraform address,
   `module.<name>.module.security_group.aws_security_group.default[0]`.
2. List the old rules:

   ```sh
   terraform state list | grep 'security_group.aws_security_group_rule.default'
   ```

3. Move each rule to its new address. The new key is `legacy[<n>]`, where `<n>` is the
   rule's position in `security_group_rules`, counting from 0. With the default rules,
   the egress rule is `legacy[0]` and the SSH rule is `legacy[1]`.

   ```sh
   terraform state mv \
     'module.<name>.module.security_group.aws_security_group_rule.default["<old key>"]' \
     'module.<name>.module.security_group.aws_security_group_rule.dbc["legacy[0]"]'
   ```

4. Run `terraform plan`. Check that it does not replace the security group or create
   or destroy any security group rules.
