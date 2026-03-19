from pipeline1.lib.config import config
from pipeline1.lib.context import get_context

def show_config() -> None:
    excluded = [
        'base_dir_name', 
        'working_dir_name', 
        'new_tab_dir_name', 
        'new_tab_dir', 
        'log_dir', 
        'log_base', 
        'temp_dir', 
        'python_root', 
        'my_download_dir',
        'indentation',
        'debug']
    for key, value in config.items():
        if key not in excluded:
            print(f"{key}:{' ' * (25 - len(key))}{value}")


    context = {
        'default_step_id': get_context('default_step_id'),
        'default_step_path': get_context('default_step_path')
    }
    for key, value in context.items():
        print(f"{key}:{' ' * (25 - len(key))}{value}")