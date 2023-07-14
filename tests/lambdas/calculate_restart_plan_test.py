import pytest
from unittest import TestCase
from unittest.mock import patch
from modules.lambdas.lambdas.calculate_restart_plan.index import *

class TestCalculateRestartPlan(TestCase):
    def test_lambda_handler_calls_initialPlan_when_event(self):
        expected = { 'detail': 'mock initial plan'}
        
        with patch(f'{initialPlan.__module__}.{initialPlan.__name__}') as _initialPlan:
            _initialPlan.return_value = expected
            
            expected_asg_name = 'asg_name1'
            event = { 
                'source': 'source1', 
                'detail-type': 'aws.events',
                'detail': {
                    'AutoScalingGroupName': expected_asg_name
                }
            }
            
            actual = lambda_handler(event, context = {})    
            _initialPlan.assert_called_once_with(expected_asg_name) 
                        
            pass    
        
        self.assertEqual(expected, actual)

    def test_lambda_handler_calls_subsequentPlan_when_not_event(self):
        expected = { 'detail': 'mock subsequent plan'}
        
        with patch(f'{subsequentPlan.__module__}.{subsequentPlan.__name__}') as _subsequentPlan:
            _subsequentPlan.return_value = expected
            
            event = {
                'some': 'event'
            }
            
            actual = lambda_handler(event, context = {})  
            _subsequentPlan.assert_called_once_with(event)  
            
            pass    
        
        self.assertEqual(expected, actual)
    
    def test_initialPlan(self):
        asg_name = 'asgName1'
        describe_asg_response = { 'AutoScalingGroups': [{ 'Instances': [
                    { 'InstanceId': 'i-0' },
                    { 'InstanceId': 'i-1' },
                    { 'InstanceId': 'i-2' },
                    { 'InstanceId': 'i-3' },
                    { 'InstanceId': 'i-4' }
                ]}
            ]}

        expected_remaining_instances = ['i-0', 'i-1', 'i-2', 'i-3', 'i-4']
        expected_queued_instances = setQueuedInstances(expected_remaining_instances)
        expected = {
            'AllInstances': expected_remaining_instances,
            'Targets': [{"Key": "InstanceIds","Values": expected_queued_instances}],
            'QueuedInstances': expected_queued_instances,
            'QueueCount': len(expected_remaining_instances),
            'AutoScalingGroupName': asg_name,
            'CompletedInstances': [],
            'FailedInstances': []
        }

        with patch('botocore.client.BaseClient._make_api_call') as _boto3:
            _boto3.return_value = describe_asg_response

            actual = initialPlan(asg_name)

            _boto3.assert_called_with('DescribeAutoScalingGroups', {
                'AutoScalingGroupNames': [str(asg_name)]
            })
            pass
        
        self.assertEqual(expected, actual)

    def test_subsequentPlan(self):
        last_event = {
            'MapResult': [
                { 'Instance_Id': 'i-0', 'Details': { 'Status': 'Success' }},
                { 'Instance_Id': 'i-1', 'Details': { 'Status': 'NotSuccess' }}
            ],
            'AllInstances': ['i-0', 'i-1', 'i-2', 'i-3', 'i-4'],
            'CompletedInstances': ['alreadyCompletedId'],
            'FailedInstances': ['alreadyFailedId'],
            'AutoScalingGroupName': 'autoScalingGroupName1'
        }

        expected_remaining_instances = ['i-2', 'i-3', 'i-4']
        expected_completed_instances = ['alreadyCompletedId', 'i-0']
        expected_failed_instances = ['alreadyFailedId', 'i-1']
        expected_queued_instances = setQueuedInstances(expected_remaining_instances)

        expected = {
            'AllInstances': expected_remaining_instances,
            'Targets': [{ 'Key': 'InstanceIds', 'Values': expected_queued_instances}],
            'QueuedInstances': expected_queued_instances,
            'QueueCount': len(expected_queued_instances),
            'AutoScalingGroupName': last_event['AutoScalingGroupName'],
            'CompletedInstances': expected_completed_instances,
            'FailedInstances': expected_failed_instances
        }

        actual = subsequentPlan(last_event)

        self.assertEqual(expected, actual)

    def test_setQueuedInstances(self):
        remaining_instances = [{ 'Instance_Id':0 },{ 'Instance_Id':1 }, { 'Instance_Id':2 }, { 'Instance_Id':3 }, { 'Instance_Id':4 }]
        expected = remaining_instances[0:2]
        actual = setQueuedInstances(remaining_instances)
        self.assertEqual(expected, actual)
