#!/usr/bin/env python
import json
import sys
import urllib

if sys.argv[1] == '--local':
    with open('metadata.json') as data_file:
        data = json.load(data_file)

    print data['version']

if sys.argv[1] == '--forge':
    url = 'https://forgeapi.puppetlabs.com/v3/modules/locp-cassandra'
    response = urllib.urlopen(url)
    data = json.loads(response.read())
    print data['current_release']['version']
