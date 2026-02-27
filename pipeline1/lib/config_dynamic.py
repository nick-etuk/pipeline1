import os
from pipeline1.lib.config import config


def get_dynamic(key:str, group: str='general') -> str:
    """Get a dynamic configuration value from the filesystem."""
    
    key = key.strip().lower()
    group = group.strip().lower()

    config_dir = os.path.join(config['working_dir'], "dynamic_config", group)
    if not os.path.isdir(config_dir):
        return ''

    status_file = os.path.join(config_dir, f"{key}.txt")
    if not os.path.isfile(status_file):
        return ''
    
    with open(status_file) as f:
        value = f.read().strip()
    return value


def set_dynamic(key:str, value: str, group: str='general') -> None:
    """
    Set a dynamic configuration value on the filesystem.
    Scopes: global, job, step, instance. Default is job.
    """
    
    key = key.strip().lower()
    value = value.strip()
    group = group.strip().lower()

    current_value = get_dynamic(key=key, group=group)
    if current_value == value:
        return
    
    config_dir = os.path.join(config['working_dir'], "dynamic_config", group)
    if not os.path.isdir(config_dir):
        os.makedirs(config_dir)

    status_file = os.path.join(config_dir, f"{key}.txt")
    with open(status_file, "w") as f:
        f.write(value)
