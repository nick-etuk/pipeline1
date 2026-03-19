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

    @patch('builtins.print')
    def test_os_mismatch_returns_early(self, mock_print: MagicMock):
        # Step specifies a different OS
        my_step = {'os': 'macos'} | self.registry_entry
        with patch('builtins.print') as mock_print:
            execute_step(step=my_step, args=[], overrides=[])
            # Should early return without running subprocess
            mock_print.assert_any_call('Step sample_step not for ubuntu')

    @patch('builtins.open')
    @patch('pipeline1.run_step.enrich_step.enrich_step')
    @patch('pipeline1.run_step.execute_step.step_entry')
    def test_step_entry_false_aborts(self, mock_step_entry: MagicMock, mock_enrich: MagicMock, mock_open_fn: MagicMock):
        mock_open_fn.return_value.__enter__.return_value = StringIO('{}')
        config = {}
        mock_enrich.return_value = config | {
            'stepId': 'sample_step',
            'title': 'Sample Step',
            'path': '/tmp/sample_step/config.json',
            'dir': '/tmp/sample_step'
        }
        mock_step_entry.return_value = {'status': False, 'reason': ''}
        with patch('subprocess.run') as mock_run:
            execute_step(step=self.registry_entry, args=[], overrides=[])
            mock_run.assert_not_called()

    @patch('builtins.open')
    @patch('pipeline1.run_step.enrich_step.enrich_step')
    @patch('pipeline1.run_step.execute_step.step_entry')
    @patch('pipeline1.run_step.execute_step.step_exit')
    def test_subprocess_called_for_unix(self, mock_step_exit: MagicMock, mock_step_entry: MagicMock, mock_enrich: MagicMock, mock_open_fn: MagicMock):
        mock_open_fn.return_value.__enter__.return_value = StringIO('{}')
        mock_step_entry.return_value = {'status': True, 'reason': ''}
        mock_step_exit.return_value = True
        config = {}
        mock_enrich.return_value = config | {
            'stepId': 'sample_step',
            'title': 'Sample Step',
            'path': '/tmp/sample_step/config.json',
            'dir': '/tmp/sample_step'
        }
        with patch('subprocess.run') as mock_run, patch('builtins.print'):
            mock_run.return_value = MagicMock(returncode=0, stdout='done')
            execute_step(step=self.registry_entry, args=['arg1'], overrides=[])
            self.assertTrue(mock_run.called)
            args_passed = mock_run.call_args[0][0]
            self.assertIn(f"{config['script_root']}/run_step_script.sh", args_passed)
            self.assertIn('/tmp/sample_step/sample_step.sh', args_passed)
    '''
    @patch('builtins.open')
    @patch('pipeline1.run_step.enrich_step.enrich_step')
    @patch('pipeline1.run_step.execute_step.step_entry')
    def test_new_tab_queue_creation_and_open_new_tab(self, mock_step_entry: MagicMock, mock_enrich: MagicMock, mock_open_fn: MagicMock):
        print('=>test_new_tab_queue_creation_and_open_new_tab')
        mock_open_fn.return_value.__enter__.return_value = StringIO('{}')
        mock_step_entry.return_value = {'status': True, 'reason': ''}
        config = {'newTab': True}
        mock_enrich.return_value = config | {
            'stepId': 'sample_step',
            'title': 'Sample Step',
            'baseFilename': 'sample_step',
            'path': '/tmp/sample_step/config.json',
            'dir': '/tmp/sample_step'
        }
        test_step = {'newTab': True} | self.registry_entry
        # Need a real JSON for first file open (config.json) but second open writes queue file; use side_effect
        def open_side_effect(filename: str, *args: Any, **kwargs: Any):
            if filename.endswith('config.json'):
                return StringIO('{}')
            # For write operations, return a mock file handle
            m = mock_open()
            return m()

        with patch('subprocess.run') as mock_run, \
             patch('pipeline1.run_step.execute_step.open_new_tab') as mock_open_tab, \
             patch('builtins.open', side_effect=open_side_effect):
            execute_step(step=test_step, args=['a', 'b'], overrides=[])
            mock_open_tab.assert_called_once()
            mock_run.assert_not_called()  # early return before subprocess

    '''

    @patch('builtins.open')
    @patch('pipeline1.run_step.enrich_step.enrich_step')
    def test_run_once_status_done_returns_early(self, mock_enrich: MagicMock, mock_open_fn: MagicMock):
        # run_once True triggers early info log and return (status hardcoded to done)
        config = {'run_once': True}
        mock_enrich.return_value = config | {
            'stepId': 'sample_step',
            'title': 'Sample Step',
            'path': '/tmp/sample_step/config.json',
            'dir': '/tmp/sample_step'
        }
        mock_open_fn.return_value.__enter__.return_value = StringIO('{}')
        with patch('pipeline1.run_step.execute_step.log.info') as mock_info, \
             patch('subprocess.run') as mock_run:
            execute_step(step=self.registry_entry, args=['x', 'y'], overrides=[])
            mock_info.assert_called_once()
            mock_run.assert_not_called()

    @patch('builtins.open')
    @patch('pipeline1.run_step.enrich_step.enrich_step')
    @patch('pipeline1.run_step.execute_step.step_entry')
    @patch('pipeline1.run_step.execute_step.step_exit')
    def test_step_exit_failure_logs_failure(self, mock_step_exit: MagicMock, mock_step_entry: MagicMock, mock_enrich: MagicMock, mock_open_fn: MagicMock):
        mock_open_fn.return_value.__enter__.return_value = StringIO('{}')
        mock_step_entry.return_value = {'status': True, 'reason': ''}
        mock_step_exit.return_value = False
        config = {}
        mock_enrich.return_value = config | {
            'stepId': 'sample_step',
            'title': 'Sample Step',
            'path': '/tmp/sample_step/config.json',
            'dir': '/tmp/sample_step',
            'baseFilename': 'sample_step'
        }
        with patch('subprocess.run') as mock_run, \
             patch('pipeline1.run_step.execute_step.log.info') as mock_info, \
             patch('builtins.print'):
            mock_run.return_value = MagicMock(returncode=0, stdout='done')
            execute_step(step=self.registry_entry, args=[], overrides=[])
            # Expect a failure log message because step_exit returned False
            logged_failure = any('step failed' in call[0][0] for call in mock_info.call_args_list)
            self.assertTrue(logged_failure)


if __name__ == '__main__':
    unittest.main()
