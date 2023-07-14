resource "aws_s3_bucket" "this" {
  bucket_prefix = lower("${var.application_name}-${var.environment}")
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_object" "calculate_restart_plan" {
  bucket      = aws_s3_bucket.this.id
  key         = "${var.application_name}/${var.environment}/calculate-restart-plan.zip"
  source      = data.archive_file.calculate_restart_plan.output_path
  source_hash = filemd5("${path.module}/lambdas/calculate_restart_plan/index.py")
}

resource "aws_s3_bucket_object" "event_publisher" {
  bucket      = aws_s3_bucket.this.id
  key         = "${var.application_name}/${var.environment}/event-publisher.zip"
  source      = data.archive_file.event_publisher.output_path
  source_hash = filemd5("${path.module}/lambdas/event_publisher/index.py")
}

resource "aws_s3_bucket_object" "autoscaling_state_machine" {
  bucket = aws_s3_bucket.this.id
  key    = "${var.application_name}/${var.environment}/autoscaling_state_machine.json"
  content = templatefile("${path.module}/state-machine/autoscaling_state_machine.template",
    {
      "account_id"       = data.aws_caller_identity.current.account_id,
      "environment"      = var.environment,
      "application_name" = var.application_name
      "region"           = var.region
    }
  )
  source_hash = filemd5("${path.module}/state-machine/autoscaling_state_machine.template")
}