# CustomAppOne
IAM Permissions required for the solution to work.

### Role Name: Custom-App-One-Operations
As the Operations team is required to interface with the AWS Account, the listed permissions define the required access.

### Role Name: Custom-App-One-EventBridge-Lambda-Role
Alows AWS Event Bridge to trigger Lambda.

### Role Name: Custom-App-One-EventBridge-StepFunction-Role
Alows AWS Event Bridge to trigger Step Functions.

### Role Name: Custom-App-One-Lambda-Execution-Role
Allows Lambda boto3 client to Describe AutoScalingGroups, and Retreive CloudWatch metrics.

### Role Name: Custom-App-One-SSM-Role
Allows Systems Manager to sendTask results back to the State Machine execution.

### Role Name: Custom-App-One-StepFunction-Role
Allows the State Machine to invoke Lambda, Publish to SNS, Initiate Systems Manager Automations, and log to CloudWatch.

