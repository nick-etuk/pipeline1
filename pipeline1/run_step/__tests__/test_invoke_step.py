import unittest
from unittest.mock import MagicMock, patch

from pipeline1.lib.config import config
from pipeline1.run_step.invoke_step import invoke_step


class TestInvokeStep(unittest.TestCase):

    def setUp(self) -> None:
        self.step = {
            'stepId': 'test_step',
            'baseFilename': 'test_step',
            'path': '/tmp/test_step'
        }

    def test_python_step_runs_with_python3_on_unix(self):
        with patch.dict(config, {'my_os': 'macos'}, clear=False), \
             patch('pipeline1.run_step.invoke_step.os.path.exists') as mock_exists, \
             patch('pipeline1.run_step.invoke_step.subprocess.run') as mock_run, \
             patch('builtins.print') as mock_print:
            mock_exists.side_effect = lambda path: path == '/tmp/test_step/test_step.py'
            mock_run.return_value = MagicMock(returncode=0, stdout='done')

            result = invoke_step(self.step, ['arg1'])

            self.assertTrue(result)
            mock_run.assert_called_once_with(
                ['python3', '/tmp/test_step/test_step.py', 'arg1'],
                capture_output=True,
                text=True,
                check=False
            )
            mock_print.assert_any_call('Step test_step exited with code 0. Output:')
            mock_print.assert_any_call('done')

    def test_python_step_returns_false_when_subprocess_fails(self):
        with patch.dict(config, {'my_os': 'win'}, clear=False), \
             patch('pipeline1.run_step.invoke_step.os.path.exists') as mock_exists, \
             patch('pipeline1.run_step.invoke_step.subprocess.run') as mock_run, \
             patch('builtins.print'):
            mock_exists.side_effect = lambda path: path == '/tmp/test_step/test_step.py'
            mock_run.return_value = MagicMock(returncode=1, stdout='failed')

            result = invoke_step(self.step, [])

            self.assertFalse(result)
            mock_run.assert_called_once_with(
                ['python', '/tmp/test_step/test_step.py'],
                capture_output=True,
                text=True,
                check=False
            )

    def test_windows_powershell_step_logs_failure_and_returns_false(self):
        with patch.dict(config, {'my_os': 'win', 'script_root': '/scripts'}, clear=False), \
             patch('pipeline1.run_step.invoke_step.os.path.exists') as mock_exists, \
             patch('pipeline1.run_step.invoke_step.subprocess.run') as mock_run, \
             patch('pipeline1.run_step.invoke_step.log.debug') as mock_debug, \
             patch('pipeline1.run_step.invoke_step.log.info') as mock_info:
            mock_exists.side_effect = lambda path: path == '/tmp/test_step/test_step.ps1'
            mock_run.return_value = MagicMock(returncode=7, stdout='pwsh failed')

            result = invoke_step(self.step, ['arg1', 'arg2'])

            self.assertFalse(result)
            mock_debug.assert_called_once_with(
                'running sub process pwsh /scripts/run_script.ps1 /tmp/test_step/test_step.ps1 arg1 arg2'
            )
            mock_run.assert_called_once_with(
                ['pwsh', '-ExecutionPolicy', 'Unrestricted', '-File', '/scripts/run_script.ps1', '/tmp/test_step/test_step.ps1', 'arg1', 'arg2'],
                capture_output=True,
                text=True,
                check=False
            )
            mock_info.assert_any_call('Step test_step exited with code 7. Output:')
            mock_info.assert_any_call('pwsh failed')

    def test_unix_shell_step_logs_failure_and_returns_false(self):
        with patch.dict(config, {'my_os': 'ubuntu', 'script_root': '/scripts'}, clear=False), \
             patch('pipeline1.run_step.invoke_step.os.path.exists') as mock_exists, \
             patch('pipeline1.run_step.invoke_step.subprocess.run') as mock_run, \
             patch('pipeline1.run_step.invoke_step.log.debug') as mock_debug, \
             patch('pipeline1.run_step.invoke_step.log.warn') as mock_warn, \
             patch('pipeline1.run_step.invoke_step.log.info') as mock_info:
            mock_exists.side_effect = lambda path: path == '/tmp/test_step/test_step.sh'
            mock_run.return_value = MagicMock(returncode=2, stdout='bash failed')

            result = invoke_step(self.step, ['arg1'])

            self.assertFalse(result)
            mock_debug.assert_called_once_with('invoke_step running script /tmp/test_step/test_step.sh arg1')
            mock_run.assert_called_once_with(
                ['bash', '/scripts/run_script.sh', '/tmp/test_step/test_step.sh', 'arg1'],
                capture_output=True,
                text=True,
                check=False
            )
            mock_warn.assert_called_once_with('Step test_step failed with code 2. Output:')
            mock_info.assert_called_once_with('bash failed')

    def test_returns_true_when_step_has_no_script(self):
        with patch.dict(config, {'my_os': 'macos', 'script_root': '/scripts'}, clear=False), \
             patch('pipeline1.run_step.invoke_step.os.path.exists', return_value=False) as mock_exists, \
             patch('pipeline1.run_step.invoke_step.subprocess.run') as mock_run:
            result = invoke_step(self.step, [])

            self.assertTrue(result)
            mock_run.assert_not_called()
            self.assertGreaterEqual(mock_exists.call_count, 3)


if __name__ == '__main__':
    unittest.main()