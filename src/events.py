import json

import boto3

from logger import logger


class Events:
    def __init__(self, bus=None, source=None, boto3_session=None):
        self.bus = bus or 'default'
        self.source = source or 'slack'
        self.boto3_session = boto3_session or boto3.Session()
        self.client = self.boto3_session.client('events')

    def publish(self, detail_type, detail, trace_header=None):
        entry = dict(
            Detail=json.dumps(detail),
            DetailType=detail_type,
            EventBusName=self.bus,
            Source=self.source,
            TraceHeader=trace_header,
        )
        params = dict(Entries=[{k: v for k, v in entry.items() if v}])
        logger.info('PUT EVENTS %s', json.dumps(params))
        return self.client.put_events(**params)
