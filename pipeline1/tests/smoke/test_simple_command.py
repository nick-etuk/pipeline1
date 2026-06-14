import unittest
import subprocess
from pipeline1.lib.config import config

class TestSimpleCommand(unittest.TestCase):

    def test_simple_command(self):
        startup_script = f"{config['script_root']}/run_commands.sh"
        process = subprocess.run(
            ['bash', startup_script, f"echo 'simple_command' >> {config['working_dir']}/tests/smoke_test.txt"],
            capture_output=True,
            text=True, check=False)
        ret_code = process.returncode
        self.assertEqual(ret_code, 0)

        output_file = f"{config['working_dir']}/tests/smoke_test.txt"
        with open(output_file, "r") as f:
            content = f.read().strip()
        self.assertIn("simple_command", content)


if __name__ == '__main__':
    unittest.main()