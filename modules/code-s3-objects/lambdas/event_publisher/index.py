## README ##
#Code retrieves a list of ASGs in the account
#Then creates an event in EventBridge for each ASG
#Another Rule in EventBridge will match the event, and trigger a Lambda invocation for each event
#############

import boto3
import logging
import json
import time
from botocore.config import Config
import os

config = Config(
  retries = {
    'max_attempts': 0
  }
)
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

asg_client = boto3.client('autoscaling')
eb_client = boto3.client('events')

def lambda_handler(event, context=None):
  env = os.environ['Environment']
  #Disabled tag filtering, instead finds all AutoscalingGroups in the account, for test only.
  # asg_tag_values = [
  #   f'dev',
  #   f'{env}xpm1',
  #   f'{env}xpm2',
  #   f'{env}xpm3'
  #   ]
  response = asg_client.describe_auto_scaling_groups(
    # Filters=[
    #     {
    #         'Name': 'Environment',
    #         'Values': asg_tag_values
    #     }
    # ]
  )
  logger.info(f"describe_auto_scaling_groups: {response}")
  parallel_processes = response['AutoScalingGroups']
  for process in parallel_processes:
    asg_name = process['AutoScalingGroupName']
    logger.info(f"ASG Name: {asg_name}")
    data = {}
    data['AutoScalingGroupName'] = asg_name
    data['principle'] = context.invoked_function_arn
    json_data = json.dumps(data)
    logger.info(f"Json Data : {json_data}")

    response = eb_client.put_events(
      Entries=[
      {
        'Source': 'aws',
        'Resources': [
          'EventBridge ARN for Rule',
          'EventBridge ARN for Event Bus'
        ],
        'DetailType': 'xpm-restart-lambda-function',
        'Detail': json_data,
        'EventBusName': f"XPMRestartEventBus-{env}"
      },
    ])
    time.sleep(2)
    logger.info(f"response: {response}")
  return event