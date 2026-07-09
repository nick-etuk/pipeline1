from typing import Any

from pipeline1.lib.context import get_context, set_context
from pipeline1.run_step.remove_docker_containers import remove_docker_containers
from pipeline1.run_step.schedule_step import schedule_step
from pipeline1.run_step.invoke_commands import invoke_step_commands
from pipeline1.run_step.get_step import get_step
from pipeline1.run_step.invoke_step import invoke_step
from pipeline1.run_step.open_new_tab import open_new_tab
from pipeline1.run_step.correct_os import correct_os
from pipeline1.lib.logging import log
from pipeline1.step_done.check_dependencies import check_dependencies
from pipeline1.step_done.step_entry import step_entry
from pipeline1.step_done.step_exit import step_exit
from pipeline1.run_step.step_timer import start_timer, stop_timer


def run_child_steps(parent_step: dict[str, Any], parent_args: list[str], parent_overrides: list[str], depth: int = 0) -> bool:
    if 'steps' not in parent_step:
        return True
    all_passed = True
    for child_step_row in parent_step['steps']:
        child_args: list[str] = []
        args = child_step_row.split(' ')
        for arg in args:
            if arg == '$@':
                child_args.extend(parent_args)
            else:
                child_args.append(arg)

        child_step_id = child_args[0]
        child_step_args = child_args[1:]
        child_step = get_step(child_step_id)
        
        log.set_indent(depth + 1)
        status = execute_step(step=child_step, args=child_step_args, overrides=parent_overrides, new_tab_active=False, depth=depth + 1)
        if not status:
            all_passed = False
    return all_passed

def execute_step(step: dict[str, Any], args: list[str], overrides: list[str], new_tab_active: bool = False, depth: int = 0) -> bool:
    # pylint: disable=too-many-branches, too-many-statements, too-many-return-statements
    step_id = step['stepId']

    if not correct_os(step):
        return True
    
    if 'isActive' in step and str(step['isActive']).lower() == 'false':
        log.end(f"Step {step_id} is inactive")
        return True

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
                return True
    
    if not run_always and 'dependencies' not in overrides:
        ok_to_proceed = step_entry(step=step, step_args=args)
        if ok_to_proceed['run_once'] is False:
            if ok_to_proceed['reason'] == 'done':
                log.end(f"{step['title']} already done")
                if run_once:
                    set_context(step_key, 'done', 'run_once')
                return True

            log.end(f"{step['title']} not attempted")
            return False

    remove_docker_containers(step)

    if not new_tab_active and 'newTab' in step and str(step['newTab']).lower() == 'true':       
        schedule_step(step=step, args=args)
        open_new_tab()
        log.end(f"{step['title']} running in parallel")
        return True
            
    log.debug(f"=>execute step {step_id}")
    all_passed = True
    
    start_time = start_timer(step_key)

    invoke_step_commands(step)

    if 'steps' in step:
        all_passed = run_child_steps(parent_step=step, parent_args=args, parent_overrides=overrides, depth=depth) and all_passed

    invoke_step(step=step, args=args)

    stop_timer(step_key, start_time)

    if not run_always:
        if not step_exit(step=step, step_args=args, new_tab_active=new_tab_active):
            all_passed = False

    if all_passed:
        log.end(f"{step['title']} step completed")
        if run_once:
            set_context(step_key, 'done', 'run_once')
    else:
        if new_tab_active:
            log.end(f"{step['title']} parallel step failed")
        else:
            log.end(f"{step['title']} step failed")

    return all_passed