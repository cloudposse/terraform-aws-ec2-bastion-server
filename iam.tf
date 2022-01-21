# AWS Managed Policies
data "aws_iam_policy" "aws_ssm_managed_instance_core" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "cloud_watch_agent_server_policy" {
  name = "CloudWatchAgentServerPolicy"
}

# Policy with additional custom permissions for bastion instances.
module "bastion_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.3.0"

  enabled = module.this.enabled && local.create_instance_profile
  context = module.this.context

  description = "Policy for the EC2 Bastion instances"
  iam_policy_statements = {
    S3Access = {
      effect     = "Allow"
      resources  = ["*"]
      conditions = []
      actions = [
        "s3:GetEncryptionConfiguration",
      ]
    }
  }
}

module "bastion_instance_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.15.0"

  enabled = module.this.enabled && local.create_instance_profile
  context = module.this.context

  instance_profile_enabled = true
  role_description         = "IAM role for the ${module.this.id} EC2 Bastion"
  principals = {
    Service = ["ec2.amazonaws.com"]
  }
  managed_policy_arns = [
    data.aws_iam_policy.aws_ssm_managed_instance_core.arn,
    data.aws_iam_policy.cloud_watch_agent_server_policy.arn,
  ]
  policy_documents = [
    module.bastion_policy.json,
  ]
}
