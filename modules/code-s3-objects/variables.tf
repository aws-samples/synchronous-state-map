variable "environment" {
  type        = string
  description = "The environment being deployed against"
}

variable "application_name" {
  type        = string
  description = "Your custom application name"
}

variable "region" {
  type        = string
  description = "The region to deploy the solution in"
}

variable "document_name" {
  type        = string
  description = "The SSM Document Name the Step Function will execute"
}