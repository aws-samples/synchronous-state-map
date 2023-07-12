
resource "aws_iam_role" "operations" {
  name               = "${local.application_name}-Operations"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.operations_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  ]
  inline_policy {
    name   = "${local.application_name}-Operations-Invoke-Lambda"
    policy = data.aws_iam_policy_document.operations_inline.json
  }
}

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

resource "aws_iam_role" "lambda_execution" {
  name               = "${local.application_name}-Lambda-Execution-Role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  inline_policy {
    name   = "${local.application_name}-Lambdas-Execution-Policy"
    policy = data.aws_iam_policy_document.lambda_execution_inline.json
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