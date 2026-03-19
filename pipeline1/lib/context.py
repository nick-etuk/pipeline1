import os
from pipeline1.lib.config import config


def get_context(key:str, scope: str='global') -> str:
    """Get a dynamic configuration value from the filesystem."""
    
    key = key.strip().lower()
    scope = scope.strip().lower()

    context_dir = os.path.join(config['working_dir'], "context", scope)
    if not os.path.isdir(context_dir):
        return ''

    status_file = os.path.join(context_dir, f"{key}.txt")
    if not os.path.isfile(status_file):
        return ''
    
    with open(status_file, 'r', encoding='utf-8') as file:
        value = file.read().strip()
    return value


def set_context(key:str, value: str, scope: str='global') -> None:
    """
    Set a dynamic configuration value on the filesystem.
    Scopes: global, job, step, instance. Default is global.
    """
    
    key = key.strip().lower()
    value = value.strip()
    scope = scope.strip().lower()

    current_value = get_context(key, scope)
    if current_value == value:
        return
    
    context_dir = os.path.join(config['working_dir'], "context", scope)
    if not os.path.isdir(context_dir):
        os.makedirs(context_dir)

    status_file = os.path.join(context_dir, f"{key}.txt")
    with open(status_file, 'w', encoding='utf-8') as file:
        file.write(value)
