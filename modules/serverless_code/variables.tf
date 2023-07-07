variable "sns_email" {
  type        = string
  description = "The SSN Notification email"
}

variable "rebuild_version" {}

variable "environment" {
  type        = string
  description = "The environment being deployed against"
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the default cf-template* bucket in the account"
}

variable "event_bridge_lambda_role" {
  type        = string
  description = "The name of the EventBridge Role that invokes Lambda"
}

variable "event_bridge_stepfunction_role" {
  type        = string
  description = "The name of the EventBridge Role that initiates StepFunctions"
}

variable "lambda_role" {
  type        = string
  description = "The name of the Lambda Role that describes AutoScaling"
}

variable "stepfunction_role" {
  type        = string
  description = "The name of the StepFunction Role"
}

