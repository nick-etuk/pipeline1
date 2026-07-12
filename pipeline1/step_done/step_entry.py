from typing import Any
from pipeline1.step_done.check_dependencies import check_dependencies
from pipeline1.lib.logging import log
from pipeline1.step_done.check_step_done import check_step_done
from pipeline1.step_done.get_checks import get_checks

def step_entry(step: dict[str, Any], step_args: list[str]) -> dict[str, Any]:
    ok_to_proceed: dict[str, Any] = {'run_once': True, 'reason': ''}
    
    if not check_dependencies(step, step_args):
        ok_to_proceed['run_once'] = False
        ok_to_proceed['reason'] = 'failed_dependencies'
        return ok_to_proceed

    if not get_checks(step):
        return ok_to_proceed

    if check_step_done(step=step, step_args=step_args, calling_function='step_entry'):
        log.info(f"{step['title']} step already done")
        ok_to_proceed['run_once'] = False
        ok_to_proceed['reason'] = 'done'
        return ok_to_proceed
    
    return ok_to_proceed