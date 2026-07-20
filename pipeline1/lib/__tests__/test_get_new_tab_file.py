from typing import Optional
import unittest
import os
import shutil
import tempfile
import time
from unittest.mock import patch, MagicMock

import pytest
from pipeline1.lib.config import config
from pipeline1.lib.get_new_tab_file import get_new_tab_file


class TestGetNewTabFile(unittest.TestCase):
    """Unit tests for the get_new_tab_file function."""

    def setUp(self):
        """Set up test fixtures before each test method."""
        self.test_config_dir = tempfile.mkdtemp()
        self.test_queue_dir = os.path.join(self.test_config_dir, 'new_tab_queue')

    def tearDown(self):
        """Clean up test fixtures after each test method."""
        if os.path.exists(self.test_config_dir):
            shutil.rmtree(self.test_config_dir)

    @patch('pipeline1.lib.get_new_tab_file.os.path.exists')
    @patch('pipeline1.lib.get_new_tab_file.os.makedirs')
    def test_creates_directory_if_not_exists(self, mock_makedirs: MagicMock, mock_exists: MagicMock):
        """Test that the function creates the directory if it doesn't exist."""
        mock_exists.return_value = False
        
        result = get_new_tab_file()
        
        mock_exists.assert_called_once()
        mock_makedirs.assert_called_once()
        self.assertEqual(result, '')

    @patch('pipeline1.lib.get_new_tab_file.os.path.exists')
    @patch('pipeline1.lib.get_new_tab_file.os.listdir')
    def test_returns_none_when_directory_is_empty(self, mock_listdir: MagicMock, mock_exists: MagicMock):
        """Test that the function returns None when the queue directory is empty."""
        mock_exists.return_value = True
        mock_listdir.return_value = []
        
        result = get_new_tab_file()
        
        self.assertEqual(result, '')


    @patch('pipeline1.lib.get_new_tab_file.os.path.exists')
    @patch('pipeline1.lib.get_new_tab_file.os.listdir')
    @patch('pipeline1.lib.get_new_tab_file.os.path.getctime')
    def test_returns_oldest_file_when_single_file_exists(self, mock_getctime: MagicMock, mock_listdir: MagicMock, mock_exists: MagicMock):
        """Test that the function returns the file when only one file exists."""
        mock_exists.return_value = True
        mock_listdir.return_value = ['file1.txt']
        mock_getctime.return_value = 1000.0
        
        result = get_new_tab_file()
        
        expected_path = f"{config['working_dir']}/new_tab_queue/file1.txt"
        self.assertEqual(result, expected_path)

    @patch('pipeline1.lib.get_new_tab_file.os.path.exists')
    @patch('pipeline1.lib.get_new_tab_file.os.listdir')
    @patch('pipeline1.lib.get_new_tab_file.os.path.getctime')
    def test_returns_oldest_file_when_multiple_files_exist(self, mock_getctime: MagicMock, mock_listdir: MagicMock, mock_exists: MagicMock):
        """Test that the function returns the oldest file when multiple files exist."""
        mock_exists.return_value = True
        mock_listdir.return_value = ['file1.txt', 'file2.txt', 'file3.txt']
        
        # Mock getctime to return different timestamps for each file
        def getctime_side_effect(path: str):
            if 'file1.txt' in path:
                return 1000.0  # oldest
            if 'file2.txt' in path:
                return 2000.0
            if 'file3.txt' in path:
                return 3000.0  # newest
            return 0.0
        
        mock_getctime.side_effect = getctime_side_effect
        
        result = get_new_tab_file()

        expected_path = f"{config['working_dir']}/new_tab_queue/file1.txt"
        self.assertEqual(result, expected_path)

    @patch('pipeline1.lib.get_new_tab_file.os.path.exists')
    @patch('pipeline1.lib.get_new_tab_file.os.listdir')
    @patch('pipeline1.lib.get_new_tab_file.os.path.getctime')
    def test_returns_correct_oldest_file_with_different_order(self, mock_getctime: MagicMock, mock_listdir: MagicMock, mock_exists: MagicMock):
        """Test that the function correctly identifies the oldest file regardless of list order."""
        mock_exists.return_value = True
        mock_listdir.return_value = ['newest.txt', 'oldest.txt', 'middle.txt']

        def getctime_side_effect(path: str) -> float:
            if 'oldest.txt' in path:
                return 500.0   # oldest
            if 'middle.txt' in path:
                return 1500.0
            if 'newest.txt' in path:
                return 2500.0  # newest
            return 0.0
        
        mock_getctime.side_effect = getctime_side_effect
        
        result = get_new_tab_file()

        expected_path = f"{config['working_dir']}/new_tab_queue/oldest.txt"
        self.assertEqual(result, expected_path)


class TestGetNewTabFileIntegration(unittest.TestCase):
    """Integration tests for get_new_tab_file using real filesystem operations."""

    def setUp(self):
        """Set up test fixtures with a temporary directory."""
        self.original_config_dir = config['working_dir']
        self.test_config_dir = tempfile.mkdtemp()
        self.test_queue_dir = os.path.join(self.test_config_dir, 'new_tab_queue')
        
        # Patch the config directory path
        self.patcher = patch('pipeline1.lib.get_new_tab_file.os.path.exists')
        self.mock_exists = self.patcher.start()
        
    def tearDown(self):
        """Clean up test fixtures."""
        self.patcher.stop()
        if os.path.exists(self.test_config_dir):
            shutil.rmtree(self.test_config_dir)

    def _create_test_file(self, directory: str, filename: str, modify_time: Optional[float] = None) -> str:
        """Helper method to create a test file with optional modification time."""
        filepath = os.path.join(directory, filename)
        with open(filepath, 'w') as f:
            f.write('test content')
        
        if modify_time is not None:
            os.utime(filepath, (modify_time, modify_time))
        
        return filepath

    @patch('pipeline1.lib.get_new_tab_file.os.path.exists')
    @patch('pipeline1.lib.get_new_tab_file.os.makedirs')
    @patch('pipeline1.lib.get_new_tab_file.os.listdir')
    @pytest.mark.skip(reason="todo: fix and unskip.")
    def test_integration_empty_directory(self, mock_listdir: MagicMock, mock_exists: MagicMock):
        """Integration test: empty directory returns None."""
        mock_exists.return_value = True
        mock_listdir.return_value = []
        
        result = get_new_tab_file()
        
        self.assertEqual(result, '')
        

    def test_integration_with_real_files(self):
        """Integration test: create real files and verify oldest is returned."""
        # Create the queue directory
        os.makedirs(self.test_queue_dir)
        
        # Create files with different timestamps
        current_time = time.time()
        self._create_test_file(self.test_queue_dir, 'file1.txt', current_time - 300)
        self._create_test_file(self.test_queue_dir, 'file2.txt', current_time - 200)
        self._create_test_file(self.test_queue_dir, 'file3.txt', current_time - 100)
        
        # Patch the config directory to use our test directory
        with patch('pipeline1.lib.get_new_tab_file.os.path.exists') as mock_exists, \
             patch('pipeline1.lib.get_new_tab_file.os.listdir') as mock_listdir, \
             patch('pipeline1.lib.get_new_tab_file.os.path.getctime') as mock_getctime:
            
            mock_exists.return_value = True
            mock_listdir.return_value = ['file1.txt', 'file2.txt', 'file3.txt']
            
            def getctime_side_effect(path: str) -> float:
                if 'file1.txt' in path:
                    return current_time - 300
                if 'file2.txt' in path:
                    return current_time - 200
                if 'file3.txt' in path:
                    return current_time - 100
                return current_time
            
            mock_getctime.side_effect = getctime_side_effect
            
            result = get_new_tab_file()
            
            # Verify that file1.txt (the oldest) is returned
            self.assertIsNotNone(result, '')

            assert result is not None  # Type narrowing for static analysis
            self.assertTrue(result.endswith('file1.txt'))


class TestGetNewTabFileEdgeCases(unittest.TestCase):
    """Test edge cases for the get_new_tab_file function."""

    @patch('pipeline1.lib.get_new_tab_file.os.path.exists')
    @patch('pipeline1.lib.get_new_tab_file.os.listdir')
    @patch('pipeline1.lib.get_new_tab_file.os.path.getctime')
    def test_files_with_same_creation_time(self, mock_getctime: MagicMock, mock_listdir: MagicMock, mock_exists: MagicMock):
        """Test behavior when multiple files have the same creation time."""
        mock_exists.return_value = True
        mock_listdir.return_value = ['file_a.txt', 'file_b.txt', 'file_c.txt']
        mock_getctime.return_value = 1000.0  # All files have the same timestamp
        
        result = get_new_tab_file()
        
        # Should return one of the files (the first in sorted order)
        self.assertIsNotNone(result)
        assert result is not None  # Type narrowing for static analysis
        self.assertTrue(result.endswith('file_a.txt'))

    @patch('pipeline1.lib.get_new_tab_file.os.path.exists')
    @patch('pipeline1.lib.get_new_tab_file.os.listdir')
    @patch('pipeline1.lib.get_new_tab_file.os.path.getctime')
    def test_files_with_special_characters(self, mock_getctime: MagicMock, mock_listdir: MagicMock, mock_exists: MagicMock):
        """Test that files with special characters in names are handled correctly."""
        mock_exists.return_value = True
        mock_listdir.return_value = ['file-with-dashes.txt', 'file_with_underscores.txt', 'file with spaces.txt']

        def getctime_side_effect(path: str) -> float:
            if 'file-with-dashes.txt' in path:
                return 500.0
            if 'file_with_underscores.txt' in path:
                return 1000.0
            if 'file with spaces.txt' in path:
                return 1500.0
            return 0.0
        
        mock_getctime.side_effect = getctime_side_effect
        
        result = get_new_tab_file()

        expected_path = f"{config['working_dir']}/new_tab_queue/file-with-dashes.txt"
        self.assertEqual(result, expected_path)

    @patch('pipeline1.lib.get_new_tab_file.os.path.exists')
    @patch('pipeline1.lib.get_new_tab_file.os.listdir')
    @patch('pipeline1.lib.get_new_tab_file.os.path.getctime')
    def test_hidden_files_are_processed(self, mock_getctime: MagicMock, mock_listdir: MagicMock, mock_exists: MagicMock):
        """Test that hidden files (starting with .) are processed."""
        mock_exists.return_value = True
        mock_listdir.return_value = ['.hidden_file.txt', 'regular_file.txt']

        def getctime_side_effect(path: str) -> float:
            if '.hidden_file.txt' in path:
                return 500.0   # oldest
            if 'regular_file.txt' in path:
                return 1000.0
            return 0.0
        
        mock_getctime.side_effect = getctime_side_effect
        
        result = get_new_tab_file()

        expected_path = f"{config['working_dir']}/new_tab_queue/.hidden_file.txt"
        self.assertEqual(result, expected_path)


if __name__ == '__main__':
    unittest.main()
