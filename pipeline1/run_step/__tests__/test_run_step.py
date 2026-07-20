import unittest
from unittest.mock import patch, MagicMock
from io import StringIO
from typing import Any

from icecream import ic
import pytest

from pipeline1.lib.config import config
# from pipeline1.run_step.execute_step import execute_step
from pipeline1.run_step.run_step import run_step


class TestRunStep(unittest.TestCase):
    """Unit tests for the run_step function."""

    def setUp(self) -> None:
        self.registry_entry: dict[str, Any] = {
            'stepId': 'test_step',
            'title': 'Test Step',
            'baseFilename': 'test_step',
            'path': '/tmp/test_step/config.json'
        }
        self.base_config = {
            # minimal config loaded from file
        }

    @patch('pipeline1.lib.logging.log.end')
    def test_os_mismatch(self, mock_log_end: MagicMock):
        current_os = config['my_os']
        # Step specifies a different OS
        my_step = {'os': 'win'} | self.registry_entry
        # execute_step(step=my_step, args=[], overrides=[])
        run_step(step_registry_entry=my_step, step_args=[], overrides=[])
        # Should log the message "Step test_step not for {current_os}"
        mock_log_end.assert_any_call(f'Step test_step not for {current_os}')


    @patch('builtins.open')
    @patch('pipeline1.run_step.enrich_step.enrich_step')
    @patch('pipeline1.step_done.step_entry')
    def test_step_entry_false_aborts(self, mock_step_entry: MagicMock, mock_enrich: MagicMock, mock_open_fn: MagicMock):
        mock_open_fn.return_value.__enter__.return_value = StringIO('{}')
        # config = {}
        # mock_enrich.return_value = config | {
        #     'stepId': 'test_step',
        #     'title': 'Test Step',
        #     'path': '/tmp/test_step/config.json',
        #     'dir': '/tmp/test_step'
        # }
        my_step = {
            'stepId': 'test_step',
            'title': 'Test Step',
            'path': '/tmp/test_step/config.json',
            'dir': '/tmp/test_step'
        } | self.registry_entry
        mock_step_entry.return_value = {'run_once': False, 'reason': ''}
        with patch('subprocess.run') as mock_run:
            # execute_step(step=self.registry_entry, args=[], overrides=[])
            run_step(step_registry_entry=my_step, step_args=[], overrides=[])
            mock_run.assert_not_called()

    @patch('builtins.open')
    @patch('pipeline1.run_step.enrich_step.enrich_step')
    @patch('pipeline1.step_done.step_entry')
    @patch('pipeline1.step_done.step_exit')
    @pytest.mark.skip(reason="todo: fix and unskip.")
    def test_subprocess_called_for_unix(self, mock_step_exit: MagicMock, mock_step_entry: MagicMock, mock_enrich: MagicMock, mock_open_fn: MagicMock):
        mock_open_fn.return_value.__enter__.return_value = StringIO('{}')
        mock_step_entry.return_value = {'run_once': True, 'reason': ''}
        mock_step_exit.return_value = True
        # config = {}
        # mock_enrich.return_value = config | {
        #     'stepId': 'test_step',
        #     'title': 'Test Step',
        #     'path': '/tmp/test_step/config.json',
        #     'dir': '/tmp/test_step'
        # }
        my_step = {
            'stepId': 'test_step',
            'title': 'Test Step',
            'path': '/tmp/test_step/config.json',
            'dir': '/tmp/test_step'
        } | self.registry_entry
        with patch('subprocess.run') as mock_run, patch('builtins.print'):
            mock_run.return_value = MagicMock(returncode=0, stdout='done')
            ic(my_step)
            run_step(step_registry_entry=my_step, step_args=['arg1'], overrides=[])
            self.assertTrue(mock_run.called)
            args_passed = mock_run.call_args[0][0]
            self.assertIn(f"{config['script_root']}/run_step_script.sh", args_passed)
            self.assertIn('/tmp/test_step/test_step.sh', args_passed)


    @patch('builtins.open')
    @patch('pipeline1.run_step.enrich_step.enrich_step')
    def test_run_once_status_done_returns_early(self, mock_enrich: MagicMock, mock_open_fn: MagicMock):
        # run_once True triggers early info log and return (status hardcoded to done)
        config = {'runOnce': True}
        mock_enrich.return_value = config | {
            'stepId': 'test_step',
            'title': 'Test Step',
            'path': '/tmp/test_step/config.json',
            'dir': '/tmp/test_step'
        }
        mock_open_fn.return_value.__enter__.return_value = StringIO('{}')
        with patch('pipeline1.run_step.execute_step.log.info') as mock_info, \
             patch('subprocess.run') as mock_run:
            run_step(step_registry_entry=self.registry_entry, step_args=['x', 'y'], overrides=[])
            # mock_info.assert_called_once()
            mock_run.assert_not_called()

    @patch('builtins.open')
    @patch('pipeline1.run_step.enrich_step.enrich_step')
    @patch('pipeline1.step_done.step_entry')
    @patch('pipeline1.step_done.step_exit')
    @pytest.mark.skip(reason="todo: fix and unskip.")
    def test_step_exit_failure_logs_failure(self, mock_step_exit: MagicMock, mock_step_entry: MagicMock, mock_enrich: MagicMock, mock_open_fn: MagicMock):
        mock_open_fn.return_value.__enter__.return_value = StringIO('{}')
        mock_step_entry.return_value = {'run_once': True, 'reason': ''}
        mock_step_exit.return_value = False
        config = {}
        mock_enrich.return_value = config | {
            'stepId': 'test_step',
            'title': 'Test Step',
            'path': '/tmp/test_step/config.json',
            'dir': '/tmp/test_step',
            'baseFilename': 'test_step'
        }
        with patch('subprocess.run') as mock_run, \
             patch('pipeline1.run_step.execute_step.log.info') as mock_info, \
             patch('builtins.print'):
            mock_run.return_value = MagicMock(returncode=0, stdout='done')
            run_step(step_registry_entry=self.registry_entry, step_args=[], overrides=[])
            # Expect a failure log message because step_exit returned False
            logged_failure = any('step failed' in call[0][0] for call in mock_info.call_args_list)
            self.assertTrue(logged_failure)


if __name__ == '__main__':
    unittest.main()
