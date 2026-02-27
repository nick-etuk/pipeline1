from typing import Any
from pipeline1.lib.logging import log
from pipeline1.step_done.check_step_done import check_step_done

def step_exit(step: dict[str, Any], step_args: list[str], new_tab_active: bool = False):
    if new_tab_active:
        return True

    if not check_step_done(step=step, step_args=step_args, calling_function='step_exit'):
        log.warn(f"{step['title']} step failed")
        return False
    
    return True
