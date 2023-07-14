module "stack" {
  #Generates a new Cloudformation Stack Id
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
    SSMRole     = var.ssm_role
    DoumentName = local.document_name
  }
  template_body = file("${path.module}/cfn/run_command.yml")
  timeouts {}
}