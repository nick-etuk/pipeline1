import unittest
import subprocess
from pipeline1.lib.config import config

class TestRunChecks(unittest.TestCase):

    def test_multiple_checks_all_pass(self):
        startup_script = f"{config['script_root']}/run_commands.sh"
        process = subprocess.run(
            ['bash', startup_script, 'test -d /tmp', 'test -d /var/tmp'],
            capture_output=True,
            text=True)
        ret_code = process.returncode
        self.assertEqual(ret_code, 0)

    def test_multiple_checks_last_one_fails(self):
        startup_script = f"{config['script_root']}/run_commands.sh"
        process = subprocess.run(
            ['bash', startup_script, 'test -d /tmp', 'test -d /tmp1'],
            capture_output=True,
            text=True)
        ret_code = process.returncode
        self.assertEqual(ret_code, 1)


if __name__ == '__main__':
    unittest.main()