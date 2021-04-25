import json
from unittest import mock

with mock.patch('urllib.request.urlopen') as mock_open:
    mock_open.headers = {'content-type': 'application/json'}
    mock_open.return_value\
        .read.return_value\
        .decode.return_value = json.dumps({'ok': True})
    from src import index


class TestIndex:
    def setup(self):
        index.SLACK_RESPONSE = {'fizz': 'buzz'}

    def test_modal(self):
        index.events.publish = mock.MagicMock()
        event = {'detail': {'trigger_id': '<trigger_id>'}}
        index.modal(event)
        index.events.publish.assert_called_once_with(
            'api/views.open',
            {'trigger_id': '<trigger_id>', **index.SLACK_RESPONSE},
        )

    def test_direct(self):
        event = {'detail': {'response_url': 'https://example.com/'}}
        ret = index.direct(event)
        exp = {'ok': True}
        assert ret == exp
