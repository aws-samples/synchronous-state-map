## README ##
#Code is triggered from an EventBridge Rule, with a specific ASG Name as input
#On the initial run, it gets the list of ASG instances, and queues instances for the StateMachine to process
#On subsequent(2 through n) calls, code is triggered from a StepFunction State Machine
#It receives the list of ASG instances, determines which remain, and queues instances for the StateMachine to process
#############

import boto3
import botocore
import logging
import datetime;
from botocore.config import Config
import math

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

NUM_OF_ITERATIONS = 7.0

config = Config(
  retries = {
    'max_attempts': 0
  }
)

asg_client = boto3.client('autoscaling')

def lambda_handler(event,context):
  if 'source' in event and (event['source'] == 'aws' or event['source'] == 'external-initiation'):
    logger.info(f"initialPlan : {event}")
    return initialPlan(event)
  else:#Event was initialzied from the loop in the State Machine
    logger.info(f"subsequentPlan : {event}")
    return subsequentPlan(event)

def initialPlan(event):
  asg_name = event['detail']['AutoScalingGroupName']
  response = asg_client.describe_auto_scaling_groups(
    AutoScalingGroupNames = [str(asg_name)]
  )
  
  logger.info(f"describe_auto_scaling_groups : {response}")
  event['AllInstances'] = response['AutoScalingGroups'][0]['Instances']
  event['ApplicationRegion'] = getAppRegion(response['AutoScalingGroups'][0])
  remaining_instances = []

  for instance in event['AllInstances']:
    remaining_instances.append(instance['InstanceId'])
  
  output_event = {}
  count = determineCount(event)
  queued_instances = setQueuedInstances(count, remaining_instances)
  output_event['AllInstances'] = event['AllInstances']
  output_event['RemainingInstances'] = remaining_instances
  output_event['Targets'] = [{"Key": "InstanceIds","Values": queued_instances}]
  output_event['QueuedInstances'] = queued_instances
  output_event['QueueCount'] = len(queued_instances)
  output_event['AutoScalingGroupName'] = asg_name
  output_event['ApplicationRegion'] = event['ApplicationRegion']
  output_event['CompletedInstances'] = []
  output_event['FailedInstances'] = []
  logger.info(f"output_event : {output_event}")
  return output_event

def subsequentPlan(last_event):
  result = last_event['MapResult']
  remaining_instances = last_event['RemainingInstances']
  completed_instances = last_event['CompletedInstances']
  failed_instances = last_event['FailedInstances']
  logger.info(f"last_event : {last_event}")
  for res in result:
    remaining_instances.remove(res['InstanceId'])
    if res['Details']['Status'] == "Success":
      completed_instances.append(res['InstanceId'])  
    else:
      failed_instances.append(res['InstanceId'])
      logger.info(f"failed instance : {res}")

  count = determineCount(last_event)
  queued_instances = setQueuedInstances(count, remaining_instances)
  output_event = {}
  output_event['AllInstances'] = last_event['AllInstances']
  output_event['RemainingInstances'] = remaining_instances
  output_event['Targets'] = [{"Key": "InstanceIds","Values": queued_instances}]
  output_event['QueuedInstances'] = queued_instances
  output_event['QueueCount'] = len(queued_instances)
  output_event['AutoScalingGroupName'] = last_event['AutoScalingGroupName']
  output_event['CompletedInstances'] = completed_instances
  output_event['FailedInstances'] = failed_instances
  logger.info(f"output_event : {output_event}")
  return output_event

def getAppRegion(asg_response):
  tags = asg_response['Tags']
  for tag in tags:
    key = tag['Key']
    if key == 'tvpt:application-region':
      return tag['Value']
  return ""

def setQueuedInstances(count, remaining_instances):
  return remaining_instances[0:count]

def determineCount(event):
  count = 0
  if 'QueueCount' in event:#Subsequent time through, count already stored in the event
     count = event['QueueCount']
  else:#First time through
    count = math.ceil(len(event['AllInstances']) / NUM_OF_ITERATIONS)#Otherwise aim to restart 20% at a time
  logger.info(f"Planned Count : {count}")

  #Adjust the planned count based on Utilization
  metric = getUtilizationMetric(event)
  logger.info(f"Utilization Metric: {metric}")
  if metric > 60:#If the metric utilization is high, slow down the restarts
    count = round(count * .8)
  logger.info(f"Count Adjusted based on Utilization: {count}")
  return count

def getUtilizationMetric(event):
  if 'ApplicationRegion' not in event:
    return 0
  now = datetime.datetime.now()
  start_time = roundTime(now - datetime.timedelta(minutes=5))
  end_time = roundTime(now)
  cloudwatch_client = boto3.client('cloudwatch')
  utilization = 0
  logger.info(f"Updated event: {event}")
  logger.info(f"Start time: {start_time}")
  logger.info(f"End time: {end_time}")
  metric = cloudwatch_client.get_metric_data(
    MetricDataQueries=[
      {
        "Expression": f'SELECT AVG(Utilization) FROM "Search/{event["ApplicationRegion"]}"',
        "Id": "q1",
        "Period": 300,
        "Label": "weight"
      }
    ],
    StartTime=start_time,
    EndTime=end_time
  )
  logger.info(f"Utilization Response: {metric}")
  response_array = metric['MetricDataResults']
  if len(response_array) != 0:
    utilization = response_array[0]['Values'][0]
    logger.info(f"Utilization in response: {utilization}")
  return utilization

def roundTime(dt=None, dateDelta=datetime.timedelta(minutes=5)):
  roundTo = dateDelta.total_seconds()
  if dt == None : dt = datetime.datetime.now()
  seconds = (dt - dt.min).seconds
  # // is a floor division, not a comment on following line:
  rounding = (seconds+roundTo/2) // roundTo * roundTo
  return (dt + datetime.timedelta(0,rounding-seconds,-dt.microsecond)).timestamp()