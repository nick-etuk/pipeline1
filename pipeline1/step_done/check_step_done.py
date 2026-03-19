from typing import Any
from pipeline1.lib.logging import log
from pipeline1.run_step.invoke_commands import invoke_commands
from pipeline1.step_done.check_docker_containers import check_docker
from pipeline1.step_done.check_run_once import check_run_once
from pipeline1.step_done.get_checks import get_checks


def check_step_done(step: dict[str, Any], step_args: list[str], calling_function: str) -> bool:
    if check_run_once(step=step, args=step_args, overrides=[]):
        return True
    
    if not check_docker('containers', step, calling_function):
        return False
    
    if not check_docker('images', step, calling_function):
        return False
    
    checks = get_checks(step)
    if len(checks) == 0:
        return True

        # is this needed? empty checks should be allowed to mean "no checks to run"
        # if calling_function in ['step_exit', 'check_dependencies']:
        #     return True
        # warn(f"Empty checks defined for step {step['stepId']}")
        # return False

    status = invoke_commands(checks)
    if status:
        return True
    
    if calling_function == 'step_exit':
        log.warn(f"{step['stepId']} {' '.join(step_args)} step failed")
        log.info(f"Checks: {','.join(checks)}")
        # show_help(step['stepId'])
    return False
    