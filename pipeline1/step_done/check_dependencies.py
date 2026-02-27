from typing import Any
from pipeline1.lib.logging import log
from pipeline1.run_step.load_step import load_step
from pipeline1.step_done.check_step_done import check_step_done
from pipeline1.step_done.wait_for_parallel import wait_for_parallel


def check_steps(parallel_mode:bool, steps: list[dict[str, Any]], args: list[str]) -> bool:
    for step in steps:
        if parallel_mode:
            if wait_for_parallel(step, args):
                continue
        else:
            if check_step_done(step=step, step_args=args, calling_function='check_dependencies'):
                continue

        log.warn(f"Dependency {step['step_id']} is not done")
        return False
    
    return True

def check_dependencies(step: dict[str, Any], args: list[str]) -> bool:
    if 'dependencies' not in step:
        return True

    serial_steps: list[dict[str, Any]] = []
    parallel_steps: list[dict[str, Any]] = []
    for dependency in step['dependencies']:
        dependency_step = load_step(dependency)

        if 'newTab' in dependency_step and str(dependency_step['newTab']).lower() == 'true':
            parallel_steps.append(dependency_step)
        else:
            serial_steps.append(dependency_step)
    
    # Check serial dependencies before parallel ones
    if not check_steps(parallel_mode=False, steps=serial_steps, args=args):
        return False
    if not check_steps(parallel_mode=True, steps=parallel_steps, args=args):
        return False
    
    return True
