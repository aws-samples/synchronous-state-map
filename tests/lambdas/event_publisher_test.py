import pytest
import json
from unittest import TestCase
from unittest.mock import patch
from modules.lambdas.lambdas.event_publisher.index import lambda_handler

class LambdaContext:
  invoked_function_arn: str = ''

class TestEventPublisher(TestCase):
    def test_lambda_handler(self):
        
        event = { 'detail': 'input event' }
        describe_asgs_response = {
            'AutoScalingGroups': [
                { 'AutoScalingGroupName': 'asg1' },
                { 'AutoScalingGroupName': 'asg2' }
            ]
        }
        expected_function_arn = 'functionArn1'
        context = LambdaContext()
        context.invoked_function_arn = expected_function_arn
   
        with patch('botocore.client.BaseClient._make_api_call') as _boto3:
            _boto3.return_value = describe_asgs_response

            actual = lambda_handler(event, context)

            _boto3.assert_any_call('DescribeAutoScalingGroups', {})
            
            for asg in describe_asgs_response['AutoScalingGroups']:
                data = {
                    'AutoScalingGroupName': asg['AutoScalingGroupName'],
                    'principle': context.invoked_function_arn
                }
                expected_entries = [
                    {
                        'Source': 'aws',
                        'Resources': [
                        'EventBridge ARN for Rule',
                        'EventBridge ARN for Event Bus'
                        ],
                        'DetailType': 'xpm-restart-lambda-function',
                        'Detail': json.dumps(data),
                        'EventBusName': 'xpm-restart-eventbus'
                    }
                ]

                _boto3.assert_any_call('PutEvents', {
                    'Entries': expected_entries
                })
                    
            pass
        
        self.assertEqual(event, actual)
