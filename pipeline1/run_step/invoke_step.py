
from typing import Any
import os
import subprocess
from pipeline1.lib.config import config
from pipeline1.lib.logging import log
# from icecream import ic


def invoke_step(step: dict[str, Any], args: list[str]) -> None:
    # todo: make get_script_path return executable name also,
    # then use it.

    parent_step_id = step['step_id']
    
    if args and len(args) > 0:
        log.debug(f"Running step {parent_step_id} with args: {args}")
    else:
        log.debug(f"Running step {parent_step_id}")
    
    base_filename = os.path.join(step['path'], f"{step['base_filename']}")
    python_executable = 'python' if config['my_os'] == 'win' else 'python3'
    if os.path.exists(f"{base_filename}.py"):
        step_script = f"{base_filename}.py"
        process = subprocess.run([python_executable, step_script] + args)
        print(f"Step {parent_step_id} exited with code {process.returncode}. Output:")
        print(process.stdout)
        return
    
    if os.path.exists(f"{base_filename}.pl"):
        step_script = f"{base_filename}.pl"
        process = subprocess.run(['perl', step_script] + args)
        print(f"Step {parent_step_id} exited with code {process.returncode}. Output:")
        print(process.stdout)
        return
    
    if config['my_os'] == 'win':
        startup_script = os.path.join(config['script_root'], 'run_script.ps1')
        step_script = f"{base_filename}.ps1"
        log.debug(f"running sub process pwsh {startup_script} {step_script} {' '.join(args)}")
        if os.path.exists(step_script):
            process = subprocess.run(['pwsh', '-ExecutionPolicy', 'Unrestricted', '-File', startup_script, step_script, *args])
            if process.returncode != 0:
                log.info(f"Step {parent_step_id} exited with code {process.returncode}. Output:")
                log.info(process.stdout.decode() if process.stdout else "")
        return
    
    startup_script = os.path.join(config['script_root'], 'run_script.sh')
    step_script = f"{base_filename}.sh"
    if os.path.exists(step_script):
        log.debug(f"invoke_step running script {step_script} {' '.join(args)}")
        # process = subprocess.run([startup_script, step_script]+ args, shell=True, executable='/usr/local/bin/zsh')
        process = subprocess.run(['bash', startup_script, step_script]+ args)
        if process.returncode != 0:
            log.warn(f"Step {parent_step_id} failed with code {process.returncode}. Output:")
            log.info(process.stdout.decode() if process.stdout else "")