import os
from pipeline1.lib.config import config
from pipeline1.lib.logging import log

def encode_variables_in_path(path: str) -> str:
    '''
    Replaces hardcoded paths in the given path with environment variables if they match.
    For example, if the path is "/Users/username/projects/myproject" 
    and the environment variable "HOME" is set to "/Users/username", 
    then the function will return "$HOME/projects/myproject".
    '''
    new_path = path

    # Do custom replacements first
    custom_env_vars = {
        'REPO_DIR': config['repo_dir'],
    }
    for key, value in custom_env_vars.items():
        if value and new_path.startswith(value):
            new_path = new_path.replace(value, f"${key}")
    
    for key, value in os.environ.items():
        if new_path.startswith(value):
            new_path = new_path.replace(value, f"${key}")

    return new_path


def decode_variables_in_path(path: str) -> str:
    '''
    Replaces environment variables in the given path with their actual values.
    For example, if the path is "$HOME/projects/myproject" 
    and the environment variable "HOME" is set to "/Users/username", 
    then the function will return "/Users/username/projects/myproject".
    '''
    new_path = path

    # Do custom replacements first
    custom_env_vars = {
        'REPO_DIR': config['repo_dir'],
    }
    for key, value in custom_env_vars.items():
        if value and new_path.startswith(f"${key}"):
            new_path = new_path.replace(f"${key}", value)
    
    for key, value in os.environ.items():
        if new_path.startswith(f"${key}"):
            new_path = new_path.replace(f"${key}", value)

    return new_path


def expand_path(path: str) -> str:
    decoded_path = decode_variables_in_path(path)
    expanded_path = os.path.expandvars(decoded_path)
    if ('$' in path or '~' in path) and expanded_path == path:
        log.warn(f"set_default_step: path contains unexpanded environment variable: {expanded_path}")

    if not os.path.isdir(expanded_path):
        log.warn(f"set_default_step: path does not exist: {expanded_path}")
        return ''
    return expanded_path
