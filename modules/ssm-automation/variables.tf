variable "rebuild_version" {}

variable "environment" {
  type        = string
  description = "The environment being deployed for"
}

variable "ssm_role" {
  type        = string
  description = "The name of the SSM Role that the document Assumes"
}

variable "application_name" {
  type        = string
  description = "The environment being deployed against"
}

variable "sns_arn" {
  type        = string
  description = "Cloudformation notifications"
}