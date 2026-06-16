import unittest
import pytest

from pipeline1.lib.config import config
from pipeline1.registry.get_registries import get_registries
from pipeline1.run_step.run_step import run_step_by_id

class TestSimpleStep(unittest.TestCase):
    @pytest.mark.smoke_test
    def test_simple_step(self):
        _, step_registry = get_registries()         

        run_step_by_id('simple_step', [], step_registry)
        output_file = f"{config['working_dir']}/tests/run_step.txt"
        with open(output_file, "r") as f:
            content = f.read().strip()
        self.assertIn("simple_step", content)


if __name__ == "__main__":
    unittest.main()