module "iam" {
  #Creates IAM Permissions for this solution
  source           = "../../modules/iam"
  environment      = var.environment
  application_name = var.application_name
}

module "code_s3_objects" {
  #Creates an S3 bucket, and places Lambda code and State Machine definitions into S3 for reference
  source           = "../../modules/code_s3_objects"
  environment      = var.environment
  application_name = var.application_name
}

module "automation_document" {
  #Creates a Systems Manager Automation document, for execution against an EC2 instance
  source           = "../../modules/ssm_automation"
  rebuild_version  = 1 #Increment to rebuild the CloudFormation stack
  environment      = var.environment
  application_name = var.application_name
  ssm_role         = module.iam.ssm_role_name
}

module "serverless_code" {
  source                         = "../../modules/serverless_code"
  rebuild_version                = 1 #Increment to rebuild the CloudFormation stack
  sns_email                      = var.owner_email
  environment                    = var.environment
  application_name               = var.application_name
  s3_bucket_name                 = module.code_s3_objects.bucket_id
  event_bridge_lambda_role       = module.iam.eventbridge_lambda_role_name
  event_bridge_stepfunction_role = module.iam.eventbridge_lambda_role_name
  lambda_role                    = module.iam.lambda_execution_role_name
  stepfunction_role              = module.iam.stepfunction_role_name

  depends_on = [module.automation_document, module.code_s3_objects]
}