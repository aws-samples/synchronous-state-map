resource "aws_iam_role" "eventbridge_lambda" {
  name               = "${local.application_name}-EventBridge-Lambda-Role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role.json
  inline_policy {
    name   = "${local.application_name}-EventBridge-Lambda-Role"
    policy = data.aws_iam_policy_document.eventbridge_lambda_inline.json
  }
}

resource "aws_iam_role" "eventbridge_stepfunction" {
  name               = "${local.application_name}-EventBridge-StepFunction-Role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role.json
  inline_policy {
    name   = "${local.application_name}-EventBridge-StepFunction-Policy"
    policy = data.aws_iam_policy_document.eventbridge_stepfunction_inline.json
  }
}

resource "aws_iam_role" "event_publisher_lambda_execution" {
  name               = "${local.application_name}-EP-Lambda-Execution-Role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  inline_policy {
    name   = "${local.application_name}-EP-Lambdas-Execution-Policy"
    policy = data.aws_iam_policy_document.ep_lambda_execution_inline.json
  }
}

resource "aws_iam_role" "calculate_restart_plan_lambda_execution" {
  name               = "${local.application_name}-CRP-Lambda-Execution-Role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  inline_policy {
    name   = "${local.application_name}-CRP-Lambdas-Execution-Policy"
    policy = data.aws_iam_policy_document.crp_lambda_execution_inline.json
  }
}

resource "aws_iam_role" "systems_manager" {
  name               = "${local.application_name}-SSM-Role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.systems_manager_assume_role.json
  inline_policy {
    name   = "${local.application_name}-SSM-Policy"
    policy = data.aws_iam_policy_document.systems_manager_inline.json
  }
}

resource "aws_iam_role" "stepfunction" {
  name               = "${local.application_name}-StepFunction-Role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.stepfunction_assume_role.json
  inline_policy {
    name   = "${local.application_name}-StepFunction-Policy"
    policy = data.aws_iam_policy_document.stepfunction_manager_inline.json
  }
}