
from typing import Any
import os


def get_step_script(step: dict[str, Any]) -> str:
    EXTENSIONS = ['.sh','.py', '.pl', '.ps1','.bat']

    base_file_path = os.path.join(step['path'], f"{step['base_filename']}")

    for ext in EXTENSIONS:
        script_file = f"{base_file_path}{ext}"
        if os.path.exists(script_file):
            return script_file
        
    return ''
