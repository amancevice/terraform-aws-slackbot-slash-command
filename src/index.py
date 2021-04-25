import json
import os
from urllib.request import (Request, urlopen)

from events import Events
from logger import logger

EVENTS_BUS_NAME = os.getenv('EVENTS_BUS_NAME')
EVENTS_SOURCE = os.getenv('EVENTS_SOURCE')
SLACK_RESPONSE = json.loads(os.getenv('SLACK_RESPONSE') or '{}')

events = Events(bus=EVENTS_BUS_NAME, source=EVENTS_SOURCE)


@logger.attach
def modal(event, context=None):
    detail = event.get('detail') or {}
    trigger_id = detail.get('trigger_id')
    payload = {'trigger_id': trigger_id, **SLACK_RESPONSE}
    return events.publish('api/views.open', payload)


@logger.attach
def direct(event, context=None):
    detail = event.get('detail') or {}
    url = detail.get('response_url')
    channel = detail.get('channel_id')
    headers = {'content-type': 'application/json; charset=utf-8'}
    response = {'channel_id': channel, **SLACK_RESPONSE}
    data = json.dumps(response).encode('utf-8')

    # Execute request
    req = Request(url=url, data=data, headers=headers, method='POST')
    res = urlopen(req)

    # Parse response
    resdata = res.read().decode()
    ok = False
    if res.headers['content-type'].startswith('application/json'):
        resdata = json.loads(resdata)
        ok = resdata['ok']

    # Log response & return
    log = f'RESPONSE [{ res.status }]'
    logger.info(log) if ok else logger.error(log)
    return resdata
