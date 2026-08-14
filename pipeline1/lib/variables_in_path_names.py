import os
from pipeline1.lib.config import config

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