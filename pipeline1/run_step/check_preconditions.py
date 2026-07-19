from typing import Any

from pipeline1.lib.context import get_context, set_context
from pipeline1.run_step.correct_os import correct_os
from pipeline1.lib.logging import log
from pipeline1.step_done.check_dependencies import check_dependencies
from pipeline1.step_done.step_entry import step_entry


def check_preconditions(step: dict[str, Any], args: list[str], overrides: list[str]) -> bool:
    # pylint: disable=too-many-branches, too-many-return-statements
    '''
    Checks dependencies and other preconditions 
    for running a given step.

    Returns True if the step should proceed, False otherwise.
    '''

    step_id = step['stepId']

    if not correct_os(step):
        return False
    
    if 'isActive' in step and str(step['isActive']).lower() == 'false':
        log.end(f"Step {step_id} is inactive")
        return False

    log.begin(step['title'])

    if 'dependencies' not in overrides and not check_dependencies(step, args):
        log.end(f"{step['stepId']} not attempted")
        return False
    
    run_always = False
    if ('runAlways' in step and str(step['runAlways']).lower() == 'true'):
        run_always = True
        log.debug(f"runAlways is true for step {step_id}")

    step_key = f"{step_id}"

    if len(args) > 0:
        fomatted_args = "_".join(args)
        step_key = f"{step_id}_{fomatted_args}"

    run_once = False
    status = None
    if 'runOnce' in step and str(step['runOnce']).lower() == 'true':
        run_once = True
        status = get_context(step_key, 'run_once')

        if status == 'done':
            if 'runOnce' in overrides:
                log.info(f"Overriding run once for step {step_id}")
            else:
                log.end(f"{step['title']} already done")
                return False
    
    if not run_always and 'dependencies' not in overrides:
        ok_to_proceed = step_entry(step=step, step_args=args)
        if ok_to_proceed['run_once'] is False:
            if ok_to_proceed['reason'] == 'done':
                log.end(f"{step['title']} already done")
                if run_once:
                    set_context(step_key, 'done', 'run_once')
                return False

            log.end(f"{step['title']} not attempted")
            return False

    return True
