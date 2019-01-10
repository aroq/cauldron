#!/usr/bin/python

import os
from zebra_jenkins.zebra_jenkins import *
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("-f", "--file", dest="filename",
                    help="read job names from FILE", metavar="FILE")
args = parser.parse_args()

# set variables from ENV vars
queue_poll_interval = os.getenv('QUEUE_POLL_INTERVAL', 2)
job_poll_interval = os.getenv('JOB_POLL_INTERVAL', 3)
overall_timeout = os.getenv('QUEUE_POLL_INTERVAL', 3600)   # 1 hour by default
auth_token = os.getenv('JENKINS_AUTH_TOKEN', '')
jenkins_uri = os.getenv('JENKINS_HOST', 'localhost')
jenkins_port = os.getenv('JENKINS_PORT', '8080')
job_name = os.getenv('JENKINS_JOB_NAME', 'mothership')
job_values = os.getenv('JENKINS_JOB_VALUES', '')

# response = trigger_build(auth_token, jenkins_uri, jenkins_port, job_name, job_values)
# queue_id = get_build_queue_id(response)

# print executors_count


def trigger_job_if_queue_is_not_full(auth_token, jenkins_uri, jenkins_port, job_name, job_values):
    while True:
        executors_count = get_active_executors_count(auth_token, jenkins_uri, jenkins_port)
        print executors_count
        if executors_count < 3:
            response = trigger_build(auth_token, jenkins_uri, jenkins_port, job_name, job_values)
            queue_id = get_build_queue_id(response)
            break
        else:
            time.sleep(15)
    return queue_id


f = open(args.filename, 'r')
while True:
    x = f.readline()
    x = x.rstrip()
    if not x:
        break
    print x
    trigger_job_if_queue_is_not_full(auth_token, jenkins_uri, jenkins_port, x, job_values)
    time.sleep(15)

# build_id = wait_build_start(auth_token,
#                             jenkins_uri,
#                             jenkins_port,
#                             queue_id,
#                             job_name,
#                             queue_poll_interval)
#
# wait_build_finish(auth_token,
#                   jenkins_uri,
#                   jenkins_port,
#                   job_name,
#                   build_id,
#                   job_poll_interval,
#                   overall_timeout)
