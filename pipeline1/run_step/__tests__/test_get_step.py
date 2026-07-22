import csv
import json
import os
import shutil
import tempfile
import unittest
from unittest.mock import MagicMock, patch

from pipeline1.lib.config import config
from pipeline1.run_step.get_step import get_step


class TestGetStep(unittest.TestCase):

    def setUp(self) -> None:
        self.original_working_dir = config['working_dir']
        self.test_working_dir = tempfile.mkdtemp()
        self.steps_dir = os.path.join(self.test_working_dir, 'steps')
        os.makedirs(self.steps_dir)
        config['working_dir'] = self.test_working_dir
        self.step_registry_file = os.path.join(self.test_working_dir, 'step_registry.csv')

    def tearDown(self) -> None:
        config['working_dir'] = self.original_working_dir
        shutil.rmtree(self.test_working_dir)

    def write_registry(self, rows: list[dict[str, str]]) -> None:
        with open(self.step_registry_file, 'w', encoding='utf-8', newline='') as registry_file:
            writer = csv.DictWriter(registry_file, fieldnames=['stepId', 'baseFilename', 'path'])
            writer.writeheader()
            writer.writerows(rows)

    def write_step_config(self, directory: str, base_filename: str, payload: dict[str, str]) -> None:
        with open(os.path.join(directory, f'{base_filename}.json'), 'w', encoding='utf-8') as config_file:
            json.dump(payload, config_file)

    @patch('pipeline1.run_step.get_step.enrich_step')
    @patch('pipeline1.run_step.get_step.scan_all_steps')
    @patch('pipeline1.run_step.get_step.fetch_remote_projects')
    def test_returns_enriched_step_from_registry_match(
        self,
        mock_fetch_remote_projects: MagicMock,
        mock_scan_all_steps: MagicMock,
        mock_enrich_step: MagicMock,
    ) -> None:
        registry_entry = {
            'stepId': 'build_web',
            'baseFilename': 'build-web',
            'path': self.steps_dir,
        }
        base_step = {'title': 'Build Web'}
        expected_step = {'stepId': 'build_web', 'title': 'Build Web', 'path': self.steps_dir}
        self.write_registry([registry_entry])
        self.write_step_config(self.steps_dir, 'build-web', base_step)
        mock_enrich_step.return_value = expected_step

        step = get_step('build_web')

        self.assertEqual(step, expected_step)
        mock_fetch_remote_projects.assert_not_called()
        mock_scan_all_steps.assert_not_called()
        mock_enrich_step.assert_called_once_with(base_step=base_step, registry_entry=registry_entry)

    @patch('pipeline1.run_step.get_step.log')
    @patch('pipeline1.run_step.get_step.enrich_step')
    @patch('pipeline1.run_step.get_step.fetch_remote_projects')
    def test_rescans_registry_when_step_missing_initially(
        self,
        mock_fetch_remote_projects: MagicMock,
        mock_enrich_step: MagicMock,
        mock_log: MagicMock,
    ) -> None:
        registry_entry = {
            'stepId': 'build_web',
            'baseFilename': 'build-web',
            'path': self.steps_dir,
        }
        base_step = {'title': 'Build Web'}
        expected_step = {'stepId': 'build_web', 'title': 'Build Web'}
        self.write_registry([])
        self.write_step_config(self.steps_dir, 'build-web', base_step)
        mock_enrich_step.return_value = expected_step

        def populate_registry() -> None:
            self.write_registry([registry_entry])

        with patch('pipeline1.run_step.get_step.scan_all_steps', side_effect=populate_registry) as mock_scan_all_steps:
            step = get_step('build-web')

        self.assertEqual(step, expected_step)
        mock_fetch_remote_projects.assert_called_once_with()
        mock_scan_all_steps.assert_called_once_with()
        mock_log.warn.assert_called_once_with('Step build-web not found in registry. Re-scanning step registry...')
        mock_enrich_step.assert_called_once_with(base_step=base_step, registry_entry=registry_entry)

    @patch('pipeline1.run_step.get_step.log')
    @patch('pipeline1.run_step.get_step.enrich_step')
    @patch('pipeline1.run_step.get_step.fetch_remote_projects')
    def test_scans_when_registry_file_is_missing(
        self,
        mock_fetch_remote_projects: MagicMock,
        mock_enrich_step: MagicMock,
        mock_log: MagicMock,
    ) -> None:
        registry_entry = {
            'stepId': 'build_web',
            'baseFilename': 'build-web',
            'path': self.steps_dir,
        }
        base_step = {'title': 'Build Web'}
        expected_step = {'stepId': 'build_web', 'title': 'Build Web'}
        self.write_step_config(self.steps_dir, 'build-web', base_step)
        mock_enrich_step.return_value = expected_step

        def populate_registry() -> None:
            self.write_registry([registry_entry])

        with patch('pipeline1.run_step.get_step.scan_all_steps', side_effect=populate_registry) as mock_scan_all_steps:
            step = get_step('build_web')

        self.assertEqual(step, expected_step)
        mock_fetch_remote_projects.assert_called_once_with()
        mock_scan_all_steps.assert_called_once_with()
        mock_log.warn.assert_called_once_with(
            f'Step registry file {self.step_registry_file} not found. Scanning all steps...'
        )
        mock_enrich_step.assert_called_once_with(base_step=base_step, registry_entry=registry_entry)

    @patch('pipeline1.run_step.get_step.log')
    @patch('pipeline1.run_step.get_step.enrich_step')
    @patch('pipeline1.run_step.get_step.scan_all_steps')
    @patch('pipeline1.run_step.get_step.fetch_remote_projects')
    def test_returns_empty_dict_when_step_missing_after_rescan(
        self,
        mock_fetch_remote_projects: MagicMock,
        mock_scan_all_steps: MagicMock,
        mock_enrich_step: MagicMock,
        mock_log: MagicMock,
    ) -> None:
        self.write_registry([])

        step = get_step('missing-step')

        self.assertEqual(step, {})
        mock_fetch_remote_projects.assert_called_once_with()
        mock_scan_all_steps.assert_called_once_with()
        mock_enrich_step.assert_not_called()
        mock_log.warn.assert_any_call('Step missing-step not found in registry. Re-scanning step registry...')
        mock_log.warn.assert_any_call('Step missing-step still not found in registry after re-scanning. Please check the step ID and try again.')

    @patch('pipeline1.run_step.get_step.log')
    @patch('pipeline1.run_step.get_step.enrich_step')
    @patch('pipeline1.run_step.get_step.scan_all_steps')
    @patch('pipeline1.run_step.get_step.fetch_remote_projects')
    def test_uses_registry_entry_when_config_file_is_missing(
        self,
        mock_fetch_remote_projects: MagicMock,
        mock_scan_all_steps: MagicMock,
        mock_enrich_step: MagicMock,
        mock_log: MagicMock,
    ) -> None:
        registry_entry = {
            'stepId': 'build_web',
            'baseFilename': 'build-web',
            'path': self.steps_dir,
        }
        expected_step = {'stepId': 'build_web', 'path': self.steps_dir}
        self.write_registry([registry_entry])
        mock_enrich_step.return_value = expected_step

        step = get_step('build_web')

        self.assertEqual(step, expected_step)
        mock_fetch_remote_projects.assert_not_called()
        mock_scan_all_steps.assert_not_called()
        mock_log.warn.assert_called_once_with(
            f'Config file {os.path.join(self.steps_dir, "build-web.json")} not found for step build_web. Using registry entry as step.'
        )
        mock_enrich_step.assert_called_once_with(base_step={}, registry_entry=registry_entry)


if __name__ == '__main__':
    unittest.main()