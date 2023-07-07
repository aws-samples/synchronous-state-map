variable "environment" {
  type        = string
  description = "The environment being deployed against"
}

variable "application_name" {
  type        = string
  description = "The environment being deployed against"
}

variable "owner_email" {
  type        = string
  description = "Email for SNS notifications"
}