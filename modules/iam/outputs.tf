output "operations_role_name" {
  value = aws_iam_role.operations.name
}

output "eventbridge_lambda_role_name" {
  value = aws_iam_role.event_bridge_lambda.name
}

output "eventbridge_stepfunction_role_name" {
  value = aws_iam_role.event_bridge_stepfunction.name
}

output "lambda_execution_role_name" {
  value = aws_iam_role.lambda_execution.name
}

output "ssm_role_name" {
  value = aws_iam_role.systems_manager.name
}

output "stepfunction_role_name" {
  value = aws_iam_role.stepfunction.name
}