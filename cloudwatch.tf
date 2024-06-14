module "cloudwatch_logs" {
  count             = module.this.enabled && var.cloudwatch_logs_enabled == true ? 1 : 0
  source            = "cloudposse/cloudwatch-logs/aws"
  version           = "0.6.4"
  context           = module.this.context
  attributes        = ["log-group"]
  kms_key_arn       = var.kms_key_arn != "" ? var.kms_key_arn : null
  retention_in_days = var.retention_in_days
}
