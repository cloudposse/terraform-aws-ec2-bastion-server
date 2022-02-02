module "cloudwatch_logs" {
  count             = var.ssm_use_cloudwatch_logs == true ? 1 : 0
  source            = "cloudposse/cloudwatch-logs/aws"
  version           = "0.6.4"
  context           = module.this.context
  attributes        = ["log-group"]
  kms_key_arn       = var.kms_key_arn != "" ? var.kms_key_arn : null
  retention_in_days = var.retention_in_days
}

variable "ssm_use_cloudwatch_logs" {
  type        = bool
  default     = true
  description = "(Optional) Flag to enable session logs to ship to a CloudWatch log group"
}

variable "kms_key_arn" {
  description = <<-EOT
  The ARN of the KMS Key to use when encrypting log data.
  Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group.
  All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested.
  EOT
  default     = ""
}

variable "retention_in_days" {
  description = "Number of days you want to retain log events in the log group"
  default     = "30"
}