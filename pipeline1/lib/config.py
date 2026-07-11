import os
from pathlib import Path
from typing import Any
# from pipeline1.lib.context import get_context
from pipeline1.lib.detect_os import detect_os
from pipeline1.definitions import python_root


home_dir = Path.home()
my_os, vm = detect_os()

static_config: dict[str, Any] = {
    'base_dir_name': '.pipeline1',
    'working_dir_name': 'working',
    'new_tab_dir_name': 'new_tab_queue',
    'debug': True,
    'indentation': '    ',
    }

p1_root = Path(python_root).parent
repo_dir = p1_root.parent
init_path = next(p1_root.glob('**/init.sh'), None)
if not init_path:
    raise FileNotFoundError(f"init.sh not found in {p1_root}")
script_root = init_path.parent
base_dir = home_dir / static_config['base_dir_name']
working_dir = str(base_dir / static_config['working_dir_name'])

if not os.path.exists(working_dir):
    os.makedirs(working_dir, exist_ok=True)


def local_get_context(key:str) -> str:
    '''Based on pipeline1.lib.context.get_context. Created to avoid circular imports.'''
    
    key = key.strip().lower()

    context_dir = os.path.join(working_dir, 'context', 'global')
    if not os.path.isdir(context_dir):
        os.makedirs(context_dir, exist_ok=True)
        return ''

    status_file = os.path.join(context_dir, f"{key}.txt")
    if not os.path.isfile(status_file):
        return ''
    
    with open(status_file, 'r', encoding='utf-8') as file:
        value = file.read().strip()
    return value

computed_config: dict[str, Any] = {
    'p1_root': str(p1_root),
    'repo_dir': str(repo_dir),
    'python_root': python_root,
    'script_root': str(script_root),
    'my_os': my_os,
    'vm': vm,
    'base_dir': str(base_dir),
    'working_dir': str(base_dir / static_config['working_dir_name']),
    'new_tab_dir': str(base_dir / static_config['working_dir_name'] / static_config['new_tab_dir_name']),
    'log_base': str(base_dir / 'log'),
    'my_download_dir': str(base_dir / 'downloads'),
    'remotes_dir': str(base_dir / 'remote_projects'),
    'p1_user_win': local_get_context('p1_user_win'),
    'windows_home': local_get_context('windows_home'),
    'working_dir_win': local_get_context('working_dir_win'),
    'onedrive_home': local_get_context('onedrive_home'),
    'working_dir_onedrive': local_get_context('working_dir_onedrive'),
    'git_path_win': local_get_context('git_path_win'),
}

config = {**static_config, **computed_config}

if not os.path.exists(config['new_tab_dir']):
    os.makedirs(config['new_tab_dir'], exist_ok=True)
if not os.path.exists(config['remotes_dir']):
    os.makedirs(config['remotes_dir'], exist_ok=True)

# todo: project dependent configuration. move these out of core.
android_emulator_port = '5554'
loginenv = 'sandpit'

node_major_version = '22'
dotnet_major_version = '8'
python_major_version = '3.10'
    