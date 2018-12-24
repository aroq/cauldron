#!/usr/bin/python

import os
from zebra_jenkins.zebra_jenkins import *

# set variables from ENV vars
queue_poll_interval = os.getenv('QUEUE_POLL_INTERVAL', 2)
job_poll_interval = os.getenv('JOB_POLL_INTERVAL', 3)
overall_timeout = os.getenv('QUEUE_POLL_INTERVAL', 3600)   # 1 hour by default
auth_token = os.getenv('JENKINS_AUTH_TOKEN')
jenkins_uri = os.getenv('JENKINS_HOST', 'localhost')
jenkins_port = os.getenv('JENKINS_PORT', '8080')
job_name = os.getenv('JENKINS_JOB_NAME', 'mothership')
job_values = os.getenv('JENKINS_JOB_VALUES', '')

response = trigger_build(auth_token, jenkins_uri, jenkins_port, job_name, job_values)
queue_id = get_build_queue_id(response)
job_id = wait_build_start(auth_token, jenkins_uri, jenkins_port, queue_id, job_name, queue_poll_interval)
wait_build_finish(auth_token, jenkins_uri, jenkins_port, job_name, job_id, job_poll_interval, overall_timeout)
