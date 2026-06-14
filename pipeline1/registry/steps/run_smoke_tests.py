import os
import pytest

from pipeline1.lib.config import config
from pipeline1.lib.logging import log

def run_smoke_tests():
    # smoke_tests_dir = os.path.join(config['p1_root'], 'pipeline1', 'tests', 'smoke')
    smoke_tests_dir = os.path.join(config['p1_root'], 'pipeline1', 'tests')
    results_dir = os.path.join(config['working_dir'], 'tests')
    if not os.path.exists(results_dir):
        os.makedirs(results_dir, exist_ok=True)
        
    results_file = os.path.join(results_dir, 'run_step.txt')

    if os.path.exists(results_file):
        os.remove(results_file)

    results = []
    results.append(pytest.main(["-x", f"{smoke_tests_dir}", "-m", "smoke_test", "-q"]))
    # config_file = os.path.join(config['p1_root'], 'pytest.ini')
    # results.append(pytest.main(["-x", f"{smoke_tests_dir}", "-m", "smoke_test", "-c", f"{config_file}", "-vv"]))

    if any(r != 0 for r in results):
        log.error("Pipeline1 smoke tests failed.")
        sys.exit(1)