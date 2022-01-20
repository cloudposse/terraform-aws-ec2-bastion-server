module "bastion_logs" {
  source  = "cloudposse/cloudwatch-logs/aws"
  version = "0.6.4"

  enabled = module.this.context.enabled && var.enable_cloudwatch_logs
  context = module.this.context

  iam_role_enabled  = false
  retention_in_days = var.log_retention_in_days
}
