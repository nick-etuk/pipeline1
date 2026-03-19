import sys
import unittest
from unittest.mock import patch, MagicMock, mock_open
from io import StringIO
from typing import Any

from icecream import ic

from pipeline1.run_step.execute_step import execute_step


class TestExecuteStep(unittest.TestCase):
    """Unit tests for the execute_step function."""

    def setUp(self) -> None:
        self.registry_entry: dict[str, Any] = {
            'stepId': 'sample_step',
            'title': 'Sample Step',
            'baseFilename': 'sample_step',
            'path': '/tmp/sample_step/config.json'
        }
        self.base_config = {
            # minimal config loaded from file
        }

    # @patch('builtins.open')
    # @patch('pipeline1.run_step.enrich_step.enrich_step')
    # def test_os_mismatch_returns_early(self, mock_enrich: MagicMock, mock_open_fn: MagicMock):
    @patch('builtins.print')
    def test_os_mismatch_returns_early(self, mock_print: MagicMock):
        # Step specifies a different OS
        # config = {'os': 'macos'}
        # mock_enrich.return_value = config | {
        #     'stepId': self.registry_entry['stepId'],
        #     'title': 'enriched ' + self.registry_entry['title'],
        #     'baseFilename': self.registry_entry['baseFilename'],
        #     'path': self.registry_entry['path'],
        #     'dir': '/tmp/sample_step'
        # }
        my_step = {'os': 'macos'} | self.registry_entry
        # print('=>test_os_mismatch_returns_early')
        # ic(my_step)
        # mock_open_fn.return_value.__enter__.return_value = StringIO('{}')
        with patch('builtins.print') as mock_print:
            execute_step(step=my_step, args=[], overrides=[])
            # Should early return without running subprocess
            mock_print.assert_any_call('Step sample_step not for ubuntu')

    


if __name__ == '__main__':
    unittest.main()
