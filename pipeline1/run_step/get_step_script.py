
from typing import Any
import os
from pipeline1.lib.config import config

def get_step_script(step: dict[str, Any]) -> str:
    EXTENSIONS = {
        'unix': ['.sh'],
        'win': ['.ps1','.bat'],
        'independent': ['.py', '.pl']
    }

    base_file_path = os.path.join(step['path'], f"{step['baseFilename']}")

    for ext in EXTENSIONS['independent']:
        script_file = f"{base_file_path}{ext}"
        if os.path.exists(script_file):
            return script_file

    my_os = 'win' if config['my_os'] == 'win' else 'unix'
    for ext in EXTENSIONS[my_os]:
        script_file = f"{base_file_path}{ext}"
        if os.path.exists(script_file):
            return script_file
        
    return ''
