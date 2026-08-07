
from typing import Any
import os
import subprocess
from pipeline1.lib.config import config
from pipeline1.lib.logging import log
# from icecream import ic


def invoke_step(step: dict[str, Any], args: list[str]) -> bool:
    step_id = step['stepId']
    
    base_filename = os.path.join(step['path'], f"{step['baseFilename']}")
    python_executable = 'python' if config['my_os'] == 'win' else 'python3'
    return_code = 0

    if os.path.exists(f"{base_filename}.py"):
        step_script = f"{base_filename}.py"
        process = subprocess.run([python_executable, step_script] + args, capture_output=True, text=True, check=False)
        return_code = process.returncode
        print(f"Step {step_id} exited with code {return_code}. Output:")
        print(process.stdout)
        return return_code == 0
    
    if os.path.exists(f"{base_filename}.pl"):
        step_script = f"{base_filename}.pl"
        process = subprocess.run(['perl', step_script] + args, capture_output=True, text=True, check=False)
        return_code = process.returncode
        print(f"Step {step_id} exited with code {return_code}. Output:")
        print(process.stdout)
        return return_code == 0
    
    if config['my_os'] == 'win':
        startup_script = os.path.join(config['script_root'], 'run_script.ps1')
        step_script = f"{base_filename}.ps1"
        log.debug(f"running sub process pwsh {startup_script} {step_script} {' '.join(args)}")
        if os.path.exists(step_script):
            process = subprocess.run(['pwsh', '-ExecutionPolicy', 'Unrestricted', '-File', startup_script, step_script, *args], capture_output=True, text=True, check=False)
            return_code = process.returncode
            if return_code != 0:
                log.info(f"Step {step_id} exited with code {return_code}. Output:")
                log.info(process.stdout)
        
        return return_code == 0
    
    startup_script = os.path.join(config['script_root'], 'run_script.sh')
    step_script = f"{base_filename}.sh"
    if os.path.exists(step_script):
        log.debug(f"invoke_step running script {step_script} {' '.join(args)}")
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