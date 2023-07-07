module "stack" {
  #Generates a new Cloudformation Stack Id
  source          = "../stack-id"
  rebuild_version = var.rebuild_version
}

resource "aws_cloudformation_stack" "this" {
  provider = aws.ssm-automation
  capabilities = [
    "CAPABILITY_AUTO_EXPAND",
    "CAPABILITY_IAM",
    "CAPABILITY_NAMED_IAM",
  ]
  disable_rollback = false
  name             = module.stack.id
  parameters = {
    Environment     = var.environment
    SSMRole         = var.ssm_role
    ApplicationName = var.application_name
  }
  template_body = file("${path.module}/cfn/run_command.yml")
  timeouts {}
}