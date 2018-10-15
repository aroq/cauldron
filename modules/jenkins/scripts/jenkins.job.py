#!/usr/bin/python

import requests
import re
import sys
import json
import time
import os

# set variables from ENV vars
QUEUE_POLL_INTERVAL = os.getenv('QUEUE_POLL_INTERVAL', 2)
JOB_POLL_INTERVAL = os.getenv('JOB_POLL_INTERVAL', 3)
OVERALL_TIMEOUT = os.getenv('QUEUE_POLL_INTERVAL', 3600)   # 1 hour by default

auth_token = os.environ['JENKINS_AUTH_TOKEN']  # required
jenkins_uri = os.getenv('JENKINS_HOST', 'localhost')
jenkins_port = os.getenv('JENKINS_PORT', '8080')
job_name = os.getenv('JENKINS_JOB_NAME', 'mothership')
job_values = os.getenv('JENKINS_JOB_VALUES', '')

# get the crumb
crumb_get_url = 'http://{}@{}:{}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'.format(
                    auth_token, jenkins_uri, jenkins_port)
crumb = requests.get(crumb_get_url)

# set a crumb to the headers
headers = {}
crumb_parts = crumb.content.split(":")
headers[crumb_parts[0]] = crumb_parts[1]

if job_values:
    command = 'buildWithParameters'
else:
    command = 'build'

# start the build
start_build_url = 'http://{}@{}:{}/job/{}/{}?delay=0sec'.format(
        auth_token, jenkins_uri, jenkins_port, job_name, command)

job_values = {'json': job_values}
response = requests.post(start_build_url, job_values, headers)

# get a job queue location from return headers
match = re.match(r"http.+(queue.+)/", response.headers['Location'])
if not match:
    # To Do: handle error
    print "Job start request did not have queue location"
    sys.exit(1)

# poll the queue looking for job to start
queue_id = match.group(1)

job_info_url = 'http://{}@{}:{}/{}/api/json'.format(
    auth_token, jenkins_uri, jenkins_port, queue_id)

job_info_url_without_token = 'http://{}:{}/{}/api/json'.format(
    jenkins_uri, jenkins_port, queue_id)

elapsed_time = 0

print '{} Job {} added to queue: {}'.format(time.ctime(), job_name, job_info_url_without_token)

while True:
    response = requests.get(job_info_url)
    jqe = response.json()
    task = jqe['task']['name']
    try:
        job_id = jqe['executable']['number']
        break
    except requests.exceptions.RequestException:
        time.sleep(QUEUE_POLL_INTERVAL)
        elapsed_time += QUEUE_POLL_INTERVAL

    if (elapsed_time % (QUEUE_POLL_INTERVAL * 10)) == 0:
        print "{}: Job {} not started yet from {}".format(time.ctime(), job_name, queue_id)

# poll job status waiting for a result
job_url = 'http://{}@{}:{}/job/{}/{}/api/json'.format(auth_token, jenkins_uri, jenkins_port, job_name, job_id)
job_url_without_token = 'http://{}:{}/job/{}/{}/api/json'.format(jenkins_uri, jenkins_port, job_name, job_id)

start_epoch = int(time.time())

while True:
    print "{}: Job started URL: {}".format(time.ctime(), job_url_without_token)
    j = requests.get(job_url)
    jje = j.json()
    result = jje['result']
    if result == 'SUCCESS':
        print "{}: Job: {} Status: {}".format(time.ctime(), job_name, result)
        break
    elif result == 'FAILURE':
        print "{}: Job: {} Status: {}".format(time.ctime(), job_name, result)
        sys.exit(1)
    elif result == 'ABORTED':
        print "{}: Job: {} Status: {}".format(time.ctime(), job_name, result)
        sys.exit(1)
    else:
        print "{}: Job: {} Status: {}. Polling again in {} secs".format(
                time.ctime(), job_name, result, JOB_POLL_INTERVAL)

    cur_epoch = int(time.time())
    if (cur_epoch - start_epoch) > OVERALL_TIMEOUT:
        print "No status before timeout of {} secs".format(OVERALL_TIMEOUT)
        sys.exit(1)

    time.sleep(JOB_POLL_INTERVAL)
