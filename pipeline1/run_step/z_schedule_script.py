import os
from datetime import datetime
from typing import Any
from pipeline1.lib.config import config
from pipeline1.lib.logging import log
from pipeline1.run_step.get_step_script import get_step_script


def z_schedule_complex_step(step_id: str, args: list[str]) -> None:
    date_str = datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
    task_file_name = f"{step_id}_{'_'.join(args)}_{date_str}.txt"
    task_file = os.path.join(config['working_dir'], "new_tab_queue", task_file_name)
    content = f"{step_id}"
    if len(args) > 0:
        content += f"~{'~'.join(args)}"
    with open(task_file, "w") as f:
        f.write(f"{content}\n")
    log.info(f"Added {step_id} to new tab queue.")


def z_schedule_script(step: dict[str, Any], args: list[str]) -> None:
    date_str = datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
    task_file_name = f"{step['step_id']}_{'_'.join(args)}" if args else f"{step['step_id']}"
    task_file_name += f"_{date_str}.txt"
    task_file = os.path.join(config['working_dir'], "new_tab_queue", task_file_name)
    # startup script will be invoked by terminal_login.sh
    # startup_script = os.path.join(config['script_root'], 'run_step', 'run_script.sh')
    step_script = get_step_script(step)
    if not step_script:
        log.error(f"No script file found for step {step['step_id']}. Cannot schedule.")
        return

    # content = f"{startup_script} {step_script}"
    content = f"{step_script}"
    if len(args) > 0:
        content += f" {' '.join(args)}"

    with open(task_file, "w") as f:
        f.write(f"{content}\n")
    log.info(f"Added script {step_script} to new tab queue.")
    