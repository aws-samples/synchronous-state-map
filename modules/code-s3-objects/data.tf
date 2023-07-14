data "aws_caller_identity" "current" {}

data "archive_file" "calculate_restart_plan" {
  type             = "zip"
  source_dir       = "${path.module}/lambdas/calculate_restart_plan"
  output_file_mode = "0666"
  output_path      = "${path.module}/calculate-restart-plan.zip"
}

data "archive_file" "event_publisher" {
  type             = "zip"
  source_dir       = "${path.module}/lambdas/event_publisher"
  output_file_mode = "0666"
  output_path      = "${path.module}/event-publisher.zip"
}