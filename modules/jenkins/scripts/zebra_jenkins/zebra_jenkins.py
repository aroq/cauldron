import json
import requests
import re
import sys
import time


def get_active_executors_count(auth_token, jenkins_uri, jenkins_port):
    headers = prepare_headers(auth_token, jenkins_uri, jenkins_port)
    start_build_url = 'http://{}@{}:{}/computer/api/json'.format(
        auth_token, jenkins_uri, jenkins_port)
    response = requests.post(start_build_url, data={}, headers=headers)
    jqe = response.json()
    return jqe['busyExecutors']


def get_one_off_active_executors_count(auth_token, jenkins_uri, jenkins_port):
    headers = prepare_headers(auth_token, jenkins_uri, jenkins_port)
    start_build_url = 'http://{}@{}:{}/computer/api/json?depth=1'.format(
        auth_token, jenkins_uri, jenkins_port)
    response = requests.post(start_build_url, data={}, headers=headers)
    jqe = response.json()
    return len(jqe['computer'][0]['oneOffExecutors'])


def wait_for_zero_executors_count(force_quite_mode, quite_poll_period, quite_poll_tries_count, auth_token, jenkins_uri, jenkins_port):
    c = 1
    while force_quite_mode != "1" and True:
        executors_count = get_active_executors_count(auth_token, jenkins_uri, jenkins_port)
        one_off_executors_count = get_one_off_active_executors_count(auth_token, jenkins_uri, jenkins_port)
        final_executors_count = executors_count + one_off_executors_count
        queue_size = len(get_queue(auth_token, jenkins_uri, jenkins_port))
        print "Try #: {}".format(c)
        print "Executors count: {}".format(executors_count)
        print "One off executors count: {}".format(one_off_executors_count)
        print "Queue size: {}".format(queue_size)
        if final_executors_count == 0:
            break
        print "Wait for {} seconds".format(quite_poll_period)
        time.sleep(quite_poll_period)
        c = c + 1
        if c > quite_poll_tries_count:
            print "Cancel quiet down"
            set_quiet_mode("cancelQuietDown", auth_token, jenkins_uri, jenkins_port)
            print "Aborting as builds are still in progress"
            exit(1)


def get_queue(auth_token, jenkins_uri, jenkins_port):
    headers = prepare_headers(auth_token, jenkins_uri, jenkins_port)
    start_build_url = 'http://{}@{}:{}/queue/api/json'.format(
        auth_token, jenkins_uri, jenkins_port)
    response = requests.post(start_build_url, data={}, headers=headers)
    jqe = response.json()
    return jqe['items']


def set_quiet_mode(mode, auth_token, jenkins_uri, jenkins_port):
    headers = prepare_headers(auth_token, jenkins_uri, jenkins_port)
    start_build_url = 'http://{}@{}:{}/{}'.format(
        auth_token, jenkins_uri, jenkins_port, mode)
    response = requests.post(start_build_url, data={}, headers=headers)
    return response.status_code


def trigger_build(auth_token, jenkins_uri, jenkins_port, job_name, job_values):
    headers = prepare_headers(auth_token, jenkins_uri, jenkins_port)
    d = prepare_data(job_values)
    command = get_command(job_values)

    # start the build
    start_build_url = 'http://{}@{}:{}/job/{}/{}?delay=0sec'.format(
        auth_token, jenkins_uri, jenkins_port, job_name, command)
    start_build_url_without_token = 'http://{}:{}/job/{}/{}?delay=0sec'.format(
        jenkins_uri, jenkins_port, job_name, command)
    print 'BUILD URL: {}'.format(start_build_url_without_token)

    response = requests.post(start_build_url, data=d, headers=headers)
    return response


# get a job queue location from return headers
def get_build_queue_id(response):
    match = re.match(r"http.+(queue.+)/", response.headers['Location'])
    if not match:
        # To Do: handle error
        print "Job start request did not have queue location"
        sys.exit(1)

    # poll the queue looking for job to start
    return match.group(1)


def wait_build_start(auth_token, jenkins_uri, jenkins_port, queue_id, job_name, queue_poll_interval):
    job_info_url = 'http://{}@{}:{}/{}/api/json'.format(
        auth_token, jenkins_uri, jenkins_port, queue_id)

    job_info_url_without_token = 'http://{}:{}/{}/api/json'.format(
        jenkins_uri, jenkins_port, queue_id)

    elapsed_time = 0

    print '{} Job {} added to queue: {}'.format(time.ctime(), job_name, job_info_url_without_token)

    while True:
        response = requests.get(job_info_url)
        jqe = response.json()
        # task = jqe['task']['name']
        try:
            job_id = jqe['executable']['number']
            break
        except requests.exceptions.RequestException:
            time.sleep(queue_poll_interval)
            elapsed_time += queue_poll_interval

        if (elapsed_time % (queue_poll_interval * 10)) == 0:
            print "{}: Job {} not started yet from {}".format(time.ctime(), job_name, queue_id)

    return job_id


def wait_build_finish(auth_token, jenkins_uri, jenkins_port, job_name, job_id, job_poll_interval, overall_timeout):
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
                time.ctime(), job_name, result, job_poll_interval)

        cur_epoch = int(time.time())
        if (cur_epoch - start_epoch) > overall_timeout:
            print "No status before timeout of {} secs".format(overall_timeout)
            sys.exit(1)

        time.sleep(job_poll_interval)


def prepare_headers(auth_token, jenkins_uri, jenkins_port):
    # headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    headers = {}
    # set a crumb to the headers
    crumb = get_crumb(auth_token, jenkins_uri, jenkins_port)
    crumb_parts = crumb.content.split(":")
    headers[crumb_parts[0]] = crumb_parts[1]
    return headers


def prepare_data(job_values):
    if job_values:
        build_params = json.loads(job_values)
        d = {
            'json': mk_json_from_build_parameters(build_params)
        }
        d.update(build_params)
    else:
        d = {}
    return d


def get_command(job_values):
    if job_values:
        command = 'buildWithParameters'
    else:
        command = 'build'
    return command


def _mk_json_from_build_parameters(build_params, file_params=None):
    """
    Build parameters must be submitted in a particular format
    Key-Value pairs would be far too simple, no no!
    Watch and read on and behold!
    """
    if not isinstance(build_params, dict):
        raise ValueError('Build parameters must be a dict')

    build_p = [{'name': k, 'value': v}
               for k, v in sorted(build_params.items())]

    out = {'parameter': build_p}
    if file_params:
        file_p = [{'name': k, 'file': k}
                  for k in file_params.keys()]
        out['parameter'].extend(file_p)

    if len(out['parameter']) == 1:
        out['parameter'] = out['parameter'][0]

    return out


def mk_json_from_build_parameters(build_params, file_params=None):
    json_structure = _mk_json_from_build_parameters(
        build_params,
        file_params
    )
    json_structure['statusCode'] = "303"
    json_structure['redirectTo'] = "."
    return json.dumps(json_structure)


# get the crumb
def get_crumb(_auth_token, _jenkins_uri, _jenkins_port):
    crumb_get_url = 'http://{}@{}:{}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'.format(
        _auth_token, _jenkins_uri, _jenkins_port)
    return requests.get(crumb_get_url)
