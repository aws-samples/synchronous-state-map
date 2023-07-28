module "iam" {
  #Creates IAM Permissions for this solution
  source           = "../../modules/iam"
  environment      = var.environment
  application_name = var.application_name
  region           = var.region
}

resource "aws_sns_topic" "cloudformation_notications" {
  name = "cloudformation-notications"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.cloudformation_notications.arn
  protocol  = "email"
  endpoint  = var.owner_email
}

module "code_s3_objects" {
  #Creates an S3 bucket, and places Lambda code and State Machine definitions into S3 for reference
  source           = "../../modules/code-s3-objects"
  environment      = var.environment
  application_name = var.application_name
  region           = var.region
  document_name    = module.automation_document.document_name
}

module "automation_document" {
  #Creates a Systems Manager Automation document, for execution against an EC2 instance
  source           = "../../modules/ssm-automation"
  rebuild_version  = 1 #Increment to rebuild the CloudFormation stack
  environment      = var.environment
  application_name = var.application_name
  ssm_role         = module.iam.ssm_role_name
  sns_arn          = aws_sns_topic.cloudformation_notications.arn
}

module "serverless_code" {
  source                         = "../../modules/serverless-code"
  rebuild_version                = 1 #Increment to rebuild the CloudFormation stack
  sns_email                      = var.owner_email
  environment                    = var.environment
  application_name               = var.application_name
  s3_bucket_name                 = module.code_s3_objects.bucket_id
  event_bridge_lambda_role       = module.iam.eventbridge_lambda_role_name
  event_bridge_stepfunction_role = module.iam.eventbridge_lambda_role_name
  ep_lambda_role                 = module.iam.ep_lambda_execution_role_name
  crp_lambda_role                = module.iam.crp_lambda_execution_role_name
  stepfunction_role              = module.iam.stepfunction_role_name
  sns_arn                        = aws_sns_topic.cloudformation_notications.arn
}