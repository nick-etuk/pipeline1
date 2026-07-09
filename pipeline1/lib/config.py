import os
from pathlib import Path
from typing import Any
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
}

config = {**static_config, **computed_config}

if not os.path.exists(config['working_dir']):
    os.makedirs(config['working_dir'], exist_ok=True)
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
    