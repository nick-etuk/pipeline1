import os
from typing import Any
import subprocess
from pipeline1.lib.config import config
from pipeline1.lib.logging import log


def run_command(command: str) -> bool:
    command_array = []
    if config['my_os'] == 'win':
        startup_script = os.path.join(f"{config['script_root']}", 'run_commands.ps1')
        command_array = ['pwsh', '-ExecutionPolicy', 'Bypass', '-File', startup_script] + [command]
        process = subprocess.run( command_array, capture_output=True, text=True, check=False)
    else:
        startup_script = os.path.join(f"{config['script_root']}", 'run_commands.sh')
        command_array = ['bash', startup_script] + [command]
        process = subprocess.run(command_array, capture_output=True, text=True, check=False)
    
    if process.returncode != 0:
        log.debug(f"Command failed: {' '.join(command_array)}")
        log.debug(f"Return code: {process.returncode}")
        log.debug('=> stdout start')
        log.debug(process.stdout)
        log.debug('<= stdout end')
        return False

    return True


def invoke_commands(commands: list[str]) -> bool:
    result = True
    for command in commands:
        if not run_command(command):
            # log.info(f"Command failed: [{command}]")
            result = False

    return result


def invoke_step_commands(step: dict[str, Any]) -> bool:
    if 'commands' not in step:
        return True
    
    return invoke_commands(step['commands'])
