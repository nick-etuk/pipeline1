
from typing import Any
import os
import subprocess
from pipeline1.lib.config import config
from pipeline1.lib.logging import log
# from icecream import ic


def invoke_step(step: dict[str, Any], args: list[str]) -> bool:
    step_id = step['stepId']
    
    step_file_no_extension = os.path.join(step['path'], f"{step['baseFilename']}")
    python_executable = 'python' if config['my_os'] == 'win' else 'python3'
    return_code = 0

    if os.path.exists(f"{step_file_no_extension}.py"):
        step_script = f"{step_file_no_extension}.py"
        process = subprocess.run([python_executable, step_script] + args, capture_output=True, text=True, check=False)
        return_code = process.returncode
        print(f"Step {step_id} exited with code {return_code}. Output:")
        print(process.stdout)
        return return_code == 0
    
    if os.path.exists(f"{step_file_no_extension}.pl"):
        step_script = f"{step_file_no_extension}.pl"
        process = subprocess.run(['perl', step_script] + args, capture_output=True, text=True, check=False)
        return_code = process.returncode
        print(f"Step {step_id} exited with code {return_code}. Output:")
        print(process.stdout)
        return return_code == 0
    log.debug(f"invoke_step: step_id: {step_id}, step_file_no_extension: {step_file_no_extension}, args: {args} my_os: {config['my_os']}")
    if config['my_os'] == 'win':
        startup_script = os.path.join(config['script_root'], 'run_script.ps1')
        step_script = f"{step_file_no_extension}.ps1"
        log.debug(f"running sub process pwsh {startup_script} {step_script} {' '.join(args)}")
        if os.path.exists(step_script):
            process = subprocess.run(['pwsh', '-ExecutionPolicy', 'Unrestricted', '-File', startup_script, step_script, *args], capture_output=True, text=True, check=False)
            return_code = process.returncode
            if return_code != 0:
                log.info(f"Step {step_id} exited with code {return_code}. Output:")
                log.info(process.stdout)
        
        return return_code == 0
    
    startup_script = os.path.join(config['script_root'], 'run_script.sh')
    step_script = f"{step_file_no_extension}.sh"
    if os.path.exists(step_script):
        log.debug(f"Invoke_step running {step['baseFilename']}.sh")
        log.debug(f"Startup script: {startup_script}")
        log.debug(f"Step script: {step_script}")
        log.debug(f"Args: {' '.join(args)}")
        # process = subprocess.run([startup_script, step_script]+ args, shell=True, executable='/usr/local/bin/zsh')
        process = subprocess.run(['bash', startup_script, step_script]+ args, capture_output=True, text=True, check=False)
        return_code = process.returncode
        if return_code != 0:
            log.warn(f"Step {step_id} failed with code {return_code}. Output:")
            log.info(process.stdout)
            
        return return_code == 0

    # It is possible that a step has no script, but only child steps.
    # In that case, we return True to indicate that the step completed successfully.
    return True