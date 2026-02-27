
import subprocess
from typing import Any
from pipeline1.lib.logging import log


def check_docker(type: str, step: dict[str, Any], calling_function: str) -> bool:
    if type == 'containers':
        commandline = ['docker', 'container', 'ls', '--format', '{{.Names}}']
        config_property = 'dockerContainers'
    elif type == 'images':
        # commandline = ['docker', 'image', 'ls', '--format', '{{.Repository}}:{{.Tag}}']
        commandline = ['docker', 'image', 'ls', '--format', '{{.Repository}}']
        config_property = 'dockerImages'
    else:
        log.warn(f"Unknown docker check type: {type}")
        return False
    
    if not ('checks' in step and config_property in step['checks']):
        return True
    
    expected_items = step['checks'][config_property]
    actual_items = []
    # docker container ls --format "{{.Names}}"
    process = subprocess.run(commandline, capture_output=True, text=True)
    if process.returncode != 0:
        log.warn("Failed to list Docker containers. Is Docker running?")
        return False
    actual_items = process.stdout.strip().lower().split('\n')
    expected_items = [str(item).lower() for item in expected_items]
    missing_items = []
    unexpected_items = []
    for expected in expected_items:
        found = False
        for actual in actual_items:
            if expected in actual:
                found = True
            else:
                if actual not in unexpected_items: # avoid duplicates
                    unexpected_items.append(actual)
        if not found and expected not in missing_items:
            missing_items.append(expected)

    if len(missing_items) > 0:
        missing_items.sort()
        if not calling_function == 'wait_for_parallel':
            list = "\n".join(missing_items)
            log.warn(f"Missing Docker {type} for {step['step_id']}:")
            log.warn(f"{list}")
        return False

    if len(unexpected_items) > 0:
        unexpected_items.sort()
        if not calling_function == 'wait_for_parallel':
            list = "\n".join(unexpected_items)
            # warn(f"Unexpected Docker {type} for {step['step_id']}:")
            # warn(f"{list}")
    
    return True
