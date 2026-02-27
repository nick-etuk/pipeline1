import unittest
from unittest.mock import patch, mock_open, MagicMock
from io import StringIO
from typing import Any

from pipeline1.registry.get_registries import (
    project_registry,
    activity_registry,
    step_registry,
    get_registries,
)


class TestProjectRegistry(unittest.TestCase):

    @patch('pipeline1.registry.get_registries.os.path.exists')
    def test_returns_empty_list_when_file_missing(self, mock_exists: MagicMock):
        mock_exists.return_value = False
        result = project_registry()
        self.assertEqual(result, [])

    @patch('pipeline1.registry.get_registries.os.path.exists')
    @patch('builtins.open', new_callable=mock_open)
    def test_sorts_by_display_order(self, mock_file: MagicMock, mock_exists: MagicMock):
        mock_exists.return_value = True
        csv_data = (
            'project_id,display_order,name\n'
            'proj_c,3,Project C\n'
            'proj_a,1,Project A\n'
            'proj_b,2,Project B\n'
        )
        mock_file.return_value = StringIO(csv_data)
        result = project_registry()
        # Expect order proj_a, proj_b, proj_c
        self.assertEqual([r['project_id'] for r in result], ['proj_a', 'proj_b', 'proj_c'])

    @patch('pipeline1.registry.get_registries.os.path.exists')
    @patch('builtins.open', new_callable=mock_open)
    def test_string_sorting_vs_numeric(self, mock_file: MagicMock, mock_exists: MagicMock):
        mock_exists.return_value = True
        # Demonstrate numeric sorting: '10' comes after '2'
        csv_data = (
            'project_id,display_order,name\n'
            'proj_10,10,Project Ten\n'
            'proj_2,2,Project Two\n'
        )
        mock_file.return_value = StringIO(csv_data)
        result = project_registry()
        self.assertEqual([r['project_id'] for r in result], ['proj_2', 'proj_10'])


class TestActivityRegistry(unittest.TestCase):

    @patch('pipeline1.registry.get_registries.os.path.exists')
    def test_returns_empty_list_when_file_missing(self, mock_exists: MagicMock):
        mock_exists.return_value = False
        self.assertEqual(activity_registry(), [])

    @patch('pipeline1.registry.get_registries.os.path.exists')
    @patch('builtins.open', new_callable=mock_open)
    def test_sorts_by_display_order(self, mock_file: MagicMock, mock_exists: MagicMock):
        mock_exists.return_value = True
        csv_data = (
            'activity_id,display_order,path\n'
            'act3,3,/path/3.json\n'
            'act1,1,/path/1.json\n'
            'act2,2,/path/2.json\n'
        )
        mock_file.return_value = StringIO(csv_data)
        result = activity_registry()
        self.assertEqual([r['activity_id'] for r in result], ['act1', 'act2', 'act3'])


class TestStepRegistry(unittest.TestCase):

    @patch('pipeline1.registry.get_registries.os.path.exists')
    def test_returns_empty_list_when_file_missing(self, mock_exists: MagicMock):
        mock_exists.return_value = False
        self.assertEqual(step_registry(), [])

    @patch('pipeline1.registry.get_registries.os.path.exists')
    @patch('builtins.open', new_callable=mock_open)
    def test_sorts_by_sort_order(self, mock_file: MagicMock, mock_exists: MagicMock):
        mock_exists.return_value = True
        csv_data = (
            'step_id,sort_order\n'
            'step3,3\n'
            'step1,1\n'
            'step2,2\n'
        )
        mock_file.return_value = StringIO(csv_data)
        result = step_registry()
        self.assertEqual([r['step_id'] for r in result], ['step1', 'step2', 'step3'])

    @patch('pipeline1.registry.get_registries.os.path.exists')
    @patch('builtins.open', new_callable=mock_open)
    def test_string_sorting_vs_numeric(self, mock_file: MagicMock, mock_exists: MagicMock):
        mock_exists.return_value = True
        # Demonstrate numeric sorting: '10' comes after '2'
        csv_data = (
            'step_id,sort_order\n'
            'step10,10\n'
            'step2,2\n'
        )
        mock_file.return_value = StringIO(csv_data)
        result = step_registry()
        self.assertEqual([r['step_id'] for r in result], ['step2', 'step10'])


class TestGetRegistriesCombined(unittest.TestCase):

    @patch('pipeline1.registry.get_registries.os.path.exists')
    @patch('builtins.open', new_callable=mock_open)
    def test_returns_tuple_of_lists(self, mock_file: MagicMock, mock_exists: MagicMock):
        mock_exists.return_value = True
        # Provide different CSV contents based on filename
        project_csv = (
            'project_id,display_order,name\n'
            'p1,1,Project 1\n'
        )
        activity_csv = (
            'activity_id,display_order,path\n'
            'a1,1,/path/a1.json\n'
        )
        step_csv = (
            'step_id,sort_order\n'
            's1,1\n'
        )
        def open_side_effect(filename: str, *args: Any, **kwargs: Any):
            if filename.endswith('project_registry.csv'):
                return StringIO(project_csv)
            if filename.endswith('activity_registry.csv'):
                return StringIO(activity_csv)
            if filename.endswith('step_registry.csv'):
                return StringIO(step_csv)
            return StringIO('')

        mock_file.side_effect = open_side_effect

        project_list, step_list = get_registries()
        self.assertEqual(len(project_list), 1)
        self.assertEqual(len(step_list), 1)
        self.assertEqual(project_list[0]['project_id'], 'p1')
        self.assertEqual(step_list[0]['step_id'], 's1')


if __name__ == '__main__':
    unittest.main()
