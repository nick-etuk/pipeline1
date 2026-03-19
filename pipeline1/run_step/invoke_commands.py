import os
from typing import Any
import subprocess
from pipeline1.lib.config import config
from pipeline1.lib.logging import log


def invoke_commands(commands: list[str]) -> bool:
    if config['my_os'] == 'win':
        startup_script = os.path.join(f"{config['script_root']}", 'run_commands.ps1')
        process = subprocess.run(
            ['pwsh', '-ExecutionPolicy', 'Bypass', '-File', startup_script] + commands,
            capture_output=True, text=True, check=False)
    else:
        startup_script = os.path.join(f"{config['script_root']}", 'run_commands.sh')
        process = subprocess.run(
            ['bash', startup_script] + commands,
            capture_output=True, text=True, check=False)
    
    if process.returncode != 0:
        log.debug(f"commands: {','.join(commands)}")
        log.debug(f"Result: {process.returncode}")
        log.debug('=> stdout start')
        log.debug(process.stdout)
        log.debug('<= stdout end')
        return False
    
    return True


def invoke_step_commands(step: dict[str, Any]) -> bool:
    if 'commands' not in step:
        return True
    
    return invoke_commands(step['commands'])
