import json
from unittest.mock import MagicMock

from src.events import Events


class TestEvents:
    def setup(self):
        self.boto3_session = MagicMock()
        self.default = Events(boto3_session=self.boto3_session)
        self.subject = Events('slack', boto3_session=self.boto3_session)

    def test_bus_name(self):
        assert self.default.bus == 'default'
        assert self.subject.bus == 'slack'

    def test_publish(self):
        self.subject.publish('type', {'fizz': 'buzz'}, 'TRACE-ID')
        self.subject.boto3_session\
            .client.return_value\
            .put_events.assert_called_once_with(Entries=[{
                'Detail': json.dumps({'fizz': 'buzz'}),
                'DetailType': 'type',
                'EventBusName': 'slack',
                'Source': 'slack',
                'TraceHeader': 'TRACE-ID',
            }])
