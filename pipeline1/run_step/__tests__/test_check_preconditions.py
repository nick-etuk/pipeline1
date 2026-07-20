import unittest
from unittest.mock import patch, MagicMock
from typing import Any

from pipeline1.run_step.check_preconditions import check_preconditions


class TestCheckPreconditions(unittest.TestCase):

    def setUp(self) -> None:
        self.step: dict[str, Any] = {
            'stepId': 'my_step',
            'title': 'My Step',
        }

    # --- OS checks ---

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=False)
    def test_returns_false_when_os_mismatch(self, mock_correct_os: MagicMock):
        result = check_preconditions(step=self.step, args=[], overrides=[])
        self.assertFalse(result)
        mock_correct_os.assert_called_once_with(self.step)

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.check_dependencies', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.step_entry')
    def test_returns_true_when_os_matches(self, mock_entry: MagicMock, mock_deps: MagicMock, mock_os: MagicMock):
        mock_entry.return_value = {'run_once': True, 'reason': ''}
        result = check_preconditions(step=self.step, args=[], overrides=[])
        self.assertTrue(result)

    # --- isActive ---

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.log')
    def test_returns_false_when_step_inactive(self, mock_log: MagicMock, mock_os: MagicMock):
        step = self.step | {'isActive': 'false'}
        result = check_preconditions(step=step, args=[], overrides=[])
        self.assertFalse(result)
        mock_log.end.assert_called_once_with('Step my_step is inactive')

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.check_dependencies', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.step_entry')
    @patch('pipeline1.run_step.check_preconditions.log')
    def test_proceeds_when_step_active(self, mock_log: MagicMock, mock_entry: MagicMock, mock_deps: MagicMock, mock_os: MagicMock):
        mock_entry.return_value = {'run_once': True, 'reason': ''}
        step = self.step | {'isActive': 'True'}
        result = check_preconditions(step=step, args=[], overrides=[])
        self.assertTrue(result)

    # --- Dependencies ---

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.check_dependencies', return_value=False)
    @patch('pipeline1.run_step.check_preconditions.log')
    def test_returns_false_when_dependencies_fail(self, mock_log: MagicMock, mock_deps: MagicMock, mock_os: MagicMock):
        result = check_preconditions(step=self.step, args=[], overrides=[])
        self.assertFalse(result)
        mock_log.end.assert_any_call('my_step not attempted')

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.check_dependencies', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.step_entry')
    def test_skips_dependency_check_when_overridden(self, mock_entry: MagicMock, mock_deps: MagicMock, mock_os: MagicMock):
        mock_entry.return_value = {'run_once': True, 'reason': ''}
        result = check_preconditions(step=self.step, args=[], overrides=['dependencies'])
        self.assertTrue(result)
        mock_deps.assert_not_called()

    # --- runOnce ---

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.check_dependencies', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.get_context', return_value='done')
    @patch('pipeline1.run_step.check_preconditions.log')
    def test_returns_false_when_run_once_already_done(self, mock_log: MagicMock, mock_ctx: MagicMock, mock_deps: MagicMock, mock_os: MagicMock):
        step = self.step | {'runOnce': 'true'}
        result = check_preconditions(step=step, args=[], overrides=[])
        self.assertFalse(result)
        mock_log.end.assert_any_call('My Step already done')

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.check_dependencies', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.get_context', return_value='done')
    @patch('pipeline1.run_step.check_preconditions.step_entry')
    @patch('pipeline1.run_step.check_preconditions.log')
    def test_overrides_run_once_when_specified(self, mock_log: MagicMock, mock_entry: MagicMock, mock_ctx: MagicMock, mock_deps: MagicMock, mock_os: MagicMock):
        mock_entry.return_value = {'run_once': True, 'reason': ''}
        step = self.step | {'runOnce': 'true'}
        result = check_preconditions(step=step, args=[], overrides=['runOnce'])
        self.assertTrue(result)
        mock_log.info.assert_any_call('Overriding run once for step my_step')

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.check_dependencies', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.get_context', return_value='done')
    @patch('pipeline1.run_step.check_preconditions.log')
    def test_run_once_uses_step_key_with_args(self, mock_log: MagicMock, mock_ctx: MagicMock, mock_deps: MagicMock, mock_os: MagicMock):
        step = self.step | {'runOnce': 'true'}
        result = check_preconditions(step=step, args=['a', 'b'], overrides=[])
        self.assertFalse(result)
        mock_ctx.assert_called_once_with('my_step_a_b', 'run_once')

    # --- step_entry ---

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.check_dependencies', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.step_entry')
    @patch('pipeline1.run_step.check_preconditions.log')
    def test_returns_false_when_step_entry_says_done(self, mock_log: MagicMock, mock_entry: MagicMock, mock_deps: MagicMock, mock_os: MagicMock):
        mock_entry.return_value = {'run_once': False, 'reason': 'done'}
        result = check_preconditions(step=self.step, args=[], overrides=[])
        self.assertFalse(result)
        mock_log.end.assert_any_call('My Step already done')

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.check_dependencies', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.step_entry')
    @patch('pipeline1.run_step.check_preconditions.log')
    def test_returns_false_when_step_entry_says_failed(self, mock_log: MagicMock, mock_entry: MagicMock, mock_deps: MagicMock, mock_os: MagicMock):
        mock_entry.return_value = {'run_once': False, 'reason': 'failed_dependencies'}
        result = check_preconditions(step=self.step, args=[], overrides=[])
        self.assertFalse(result)
        mock_log.end.assert_any_call('My Step not attempted')

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.check_dependencies', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.step_entry')
    def test_returns_true_when_step_entry_says_proceed(self, mock_entry: MagicMock, mock_deps: MagicMock, mock_os: MagicMock):
        mock_entry.return_value = {'run_once': True, 'reason': ''}
        result = check_preconditions(step=self.step, args=[], overrides=[])
        self.assertTrue(result)

    # --- runAlways skips step_entry ---

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.check_dependencies', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.step_entry')
    def test_skips_step_entry_when_run_always(self, mock_entry: MagicMock, mock_deps: MagicMock, mock_os: MagicMock):
        step = self.step | {'runAlways': 'true'}
        result = check_preconditions(step=step, args=[], overrides=[])
        self.assertTrue(result)
        mock_entry.assert_not_called()

    # --- set_context called when step_entry says done and runOnce is true ---

    @patch('pipeline1.run_step.check_preconditions.correct_os', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.check_dependencies', return_value=True)
    @patch('pipeline1.run_step.check_preconditions.get_context', return_value='')
    @patch('pipeline1.run_step.check_preconditions.set_context')
    @patch('pipeline1.run_step.check_preconditions.step_entry')
    @patch('pipeline1.run_step.check_preconditions.log')
    def test_sets_context_done_when_step_entry_done_and_run_once(self, mock_log: MagicMock, mock_entry: MagicMock, mock_set_ctx: MagicMock, mock_get_ctx: MagicMock, mock_deps: MagicMock, mock_os: MagicMock):
        mock_entry.return_value = {'run_once': False, 'reason': 'done'}
        step = self.step | {'runOnce': 'true'}
        result = check_preconditions(step=step, args=[], overrides=[])
        self.assertFalse(result)
        mock_set_ctx.assert_called_once_with('my_step', 'done', 'run_once')


if __name__ == '__main__':
    unittest.main()
