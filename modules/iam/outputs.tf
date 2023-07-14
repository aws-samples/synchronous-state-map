output "eventbridge_lambda_role_name" {
  value = aws_iam_role.eventbridge_lambda.name
}

output "eventbridge_stepfunction_role_name" {
  value = aws_iam_role.eventbridge_stepfunction.name
}

output "ep_lambda_execution_role_name" {
  value = aws_iam_role.event_publisher_lambda_execution.name
}

output "crp_lambda_execution_role_name" {
  value = aws_iam_role.calculate_restart_plan_lambda_execution.name
}

output "ssm_role_name" {
  value = aws_iam_role.systems_manager.name
}

output "stepfunction_role_name" {
  value = aws_iam_role.stepfunction.name
}