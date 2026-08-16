import os
from datetime import datetime, timezone
from typing import Any
from pipeline1.lib.config import config
from pipeline1.lib.logging import log
from pipeline1.run_step.get_step_script import get_step_script


def schedule_step(step: dict[str, Any], args: list[str]) -> None:   
    date_str = datetime.now(timezone.utc).strftime("%Y_%m_%d_%H_%M_%S")
    task_file_name = f"{step['stepId']}_{'_'.join(args)}" if args else f"{step['stepId']}"
    task_file_name += f"_{date_str}.txt"
    task_file = os.path.join(config['working_dir'], "new_tab_queue", task_file_name)

    if 'steps' in step or 'commands' in step:
        # Complex step. Call p1.py with step_id and args, and let p1.py handle it.
        ## startup_script = os.path.join(config['script_root'], 'run_step', 'run_script.sh')
        ## step_script = f"{startup_script}"
        command_line = f"python3 {os.path.join(config['python_root'], 'p1.py')} {step['stepId']}"
    else:
        # Simple step. Run step script directly.
        step_script = get_step_script(step) 
        if not step_script:
            log.warn(f"Cannot schedule simple step {step['stepId']} - no script file found")
            return
        command_line = step_script
    
    if args:
        command_line += f" {' '.join(args)}"

    # New tab queue format:
    # step_script arg1 arg2 arg3...

    # old format:
    # step_id~step_complexity~step_script arg1 arg2 arg3...
    # row = f"{step['stepId']}~{step_complexity}~{step_script}"

    row = f"{command_line}"

    with open(task_file, "w") as f:
        f.write(f"{row}\n")
    log.info(f"Added command {command_line} to new tab queue.")