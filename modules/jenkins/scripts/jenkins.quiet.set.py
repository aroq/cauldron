#!/usr/bin/python

import os
from zebra_jenkins.zebra_jenkins import *

# set variables from ENV vars
auth_token = os.getenv('JENKINS_AUTH_TOKEN')
jenkins_uri = os.getenv('JENKINS_HOST', 'localhost')
jenkins_port = os.getenv('JENKINS_PORT', '8080')
quite_sleep_time = os.getenv('JENKINS_QUIET_MODE_SLEEP_TIME', 15)
quite_poll_period = os.getenv('JENKINS_QUIET_POLL_PERIOD', 5)
quite_poll_tries_count = os.getenv('JENKINS_QUIET_POLL_TRIES_COUNT', 120)
force_quite_mode = os.getenv('JENKINS_FORCE_QUIET_MODE', "0")

print "Wait for zero executors count BEFORE setting quiet mode"
wait_for_zero_executors_count(force_quite_mode, quite_poll_period, quite_poll_tries_count, auth_token, jenkins_uri, jenkins_port)

result = set_quiet_mode("quietDown", auth_token, jenkins_uri, jenkins_port)
print "Set quiet mode status: {}".format(result)

time.sleep(quite_sleep_time)

print "Wait for zero executors count AFTER setting quiet mode"
wait_for_zero_executors_count(force_quite_mode, quite_poll_period, quite_poll_tries_count, auth_token, jenkins_uri, jenkins_port)

print "Finished successfully"
