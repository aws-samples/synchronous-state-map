locals {
  application_name = "${var.application_name}-${var.environment}"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "operations_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:saml-provider/customer-saml"]
    }
    condition {
      test     = "StringEquals"
      variable = "SAML:aud"

      values = [
        "https://signin.aws.amazon.com/saml"
      ]
    }
  }
}

data "aws_iam_policy_document" "operations_inline" {
  statement {
    sid     = "OperationsInlinePolicy"
    actions = ["lambda:invokeFunction"]
    resources = [
      "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function/event_publisher*"
    ]
  }
}

data "aws_iam_policy_document" "eventbridge_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eventbridge_lambda_inline" {
  statement {
    sid     = "EventBridgeLambdaInlinePolicy"
    actions = ["lambda:invokeFunction"]
    resources = [
      "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function/event_publisher_*"
    ]
  }
}

data "aws_iam_policy_document" "eventbridge_stepfunction_inline" {
  statement {
    sid     = "1"
    actions = ["states:StartExecution"]
    resources = [
      "arn:aws:states:${var.region}:${data.aws_caller_identity.current.account_id}:stateMachine:*"
    ]
  }
  statement {
    sid     = "2"
    actions = ["cloudwatch:GetMetricData"]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_execution_inline" {
  statement {
    sid     = "1"
    actions = ["events:PutEvents"]
    resources = [
      "arn:aws:events:${var.region}:${data.aws_caller_identity.current.account_id}:event-bus/${var.application_name}-EventBus-*"
    ]
  }
  statement {
    sid     = "2"
    actions = ["cloudwatch:GetMetricData"]
    resources = [
      "*"
    ]
  }
  statement {
    sid     = "3"
    actions = ["autoscaling:DescribeAutoScalingInstances", "autoscaling:DescribeAutoScalingGroups"]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "systems_manager_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "systems_manager_inline" {
  statement {
    sid     = "1"
    actions = ["ssm:SendCommand"]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*",
      "arn:aws:ssm:${var.region}::document/AWS-RunShellScript"
    ]
  }
  statement {
    sid     = "2"
    actions = ["ssm:DescribeInstanceInformation"]
    resources = [
      "*"
    ]
  }
  statement {
    sid     = "3"
    actions = ["ssm:ListCommands", "ssm:ListCommandInvocations"]
    resources = [
      "*"
    ]
  }
  statement {
    sid     = "4"
    actions = ["states:SendTaskFailure", "states:SendTaskSuccess"]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "stepfunction_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "stepfunction_manager_inline" {
  statement {
    sid     = "1"
    actions = ["lambda:InvokeFunction"]
    resources = [
      "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:calculate_restart_plan_*"
    ]
  }
  statement {
    sid     = "2"
    actions = ["sns:Publish"]
    resources = [
      "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${var.application_name}-SNS-*"
    ]
  }
  statement {
    sid     = "3"
    actions = ["ssm:StartAutomationExecution"]
    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:automation-definition/${var.application_name}-RunCommand-*:*"
    ]
  }
  statement {
    sid     = "4"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/vendedlogs/states/${var.application_name}-Logs:*"
    ]
  }
  statement {
    sid     = "5"
    actions = ["logs:CreateLogGroup"]
    resources = [
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:*"
    ]
  }
}
