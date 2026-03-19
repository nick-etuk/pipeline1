from typing import Any
from pipeline1.lib.config_dynamic import get_dynamic


def check_run_once(step: dict[str, Any], args: list[str], overrides: list[str]) -> bool:
    '''
    Returns True if the step is a 'run once' step and has already been run.
    Returns False otherwise.
    '''
    if 'runonce' in overrides: 
        return False
    if 'runOnce' not in step: 
        return False
    if str(step['runOnce']).lower() != 'true': 
        return False

    step_id = step['stepId']
    step_key = f"step_{step_id}"
    if len(args) > 0:
        formatted_args = "_".join(args)
        step_key = f"step_{step_id}_{formatted_args}"

    if get_dynamic(step_key, 'status') == 'done':
        # log.debug(f"=>check run once: step {step_key} step already done")
        return True

        
    # log.debug(f"=>check run once: step {step_key} has not been run yet")
    return False