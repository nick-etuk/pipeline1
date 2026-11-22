from pipeline1.lib.logging import log
import os
from pipeline1.lib.config import config


def get_context(key:str, group: str='global') -> str:
    """Get a dynamic configuration value from the filesystem."""
    
    key = key.strip().lower()
    group = group.strip().lower()

    context_dir = os.path.join(config['working_dir'], "context", group)
    if not os.path.isdir(context_dir):
        log.warn (f"Context group '{group}' undefined")
        return ''

    status_file = os.path.join(context_dir, f"{key}.txt")
    if not os.path.isfile(status_file):
        log.warn(f"Context variable '{key}' undefined")
        return ''
    
    with open(status_file, 'r', encoding='utf-8') as file:
        value = file.read().strip()
    return value


def set_context(key:str, value: str, group: str='global') -> None:
    """
    Set a dynamic configuration value on the filesystem.
    Scopes: global, job, step, instance. Default is global.
    """
    
    key = key.strip().lower()
    value = value.strip()
    group = group.strip().lower()

    current_value = get_context(key, group)
    if current_value == value:
        return
    
    context_dir = os.path.join(config['working_dir'], "context", group)
    if not os.path.isdir(context_dir):
        os.makedirs(context_dir)

    status_file = os.path.join(context_dir, f"{key}.txt")
    with open(status_file, 'w', encoding='utf-8') as file:
        file.write(value)
