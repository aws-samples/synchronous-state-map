module "stack" {
  source          = "../stack-id"
  rebuild_version = var.rebuild_version
}

resource "aws_cloudformation_stack" "this" {
  capabilities = [
    "CAPABILITY_AUTO_EXPAND",
    "CAPABILITY_IAM",
    "CAPABILITY_NAMED_IAM",
  ]
  disable_rollback = false
  name             = module.stack.id
  parameters = {
    SnsEmail                    = var.sns_email,
    S3BucketName                = var.s3_bucket_name
    Environment                 = var.environment
    ApplicationName             = var.application_name
    EventBridgeStepFunctionRole = var.event_bridge_stepfunction_role
    EventBridgeLambdaRole       = var.event_bridge_lambda_role
    EPLambdaRole                = var.ep_lambda_role
    CRPLambdaRole               = var.crp_lambda_role
    StepFunctionRole            = var.stepfunction_role
  }
  template_body = file("${path.module}/cfn/serverless_code_template.yml")
  timeouts {}
  notification_arns = [var.sns_arn]
}