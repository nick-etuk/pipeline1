import os
from datetime import datetime
from pathlib import Path
from pipeline1.lib.config import config
from pipeline1.registry.add_project.list_projects import list_projects
from pipeline1.registry.remote_projects.fetch_remote_projects import fetch_remote_projects
from pipeline1.registry.steps.run_smoke_tests import run_smoke_tests
from pipeline1.registry.steps.scan_all_steps import scan_all_steps
from pipeline1.lib.logging import log
from pipeline1.registry.detect_code_changes.check_core import check_core
from pipeline1.registry.detect_code_changes.check_libs import check_libraries
from pipeline1.registry.detect_code_changes.scan_sub_directories import scan_sub_directories


def scan_dir(directory: Path, last_scan_time_param: float) -> bool:
    last_scan_time = float(last_scan_time_param)
    for entry in scan_sub_directories(directory):
        update_time = entry.stat().st_mtime
        if entry.name.endswith('.json'):
            if update_time > last_scan_time:
                log.info(f"Config changed: {entry.path}")
                log.info(f"Updated at {datetime.fromtimestamp(update_time).strftime('%Y-%m-%d %H:%M')}")
                return True
        if entry.name.endswith('.sh') or entry.name.endswith('.ps1'):
            # todo: this will detetct any change in a script file.
            # find a way to detect only new or added script files, not changes to existing ones.
            # might have to store step creation date in the step registry, and compare with that.
            if update_time > last_scan_time:
                log.info(f"Step changed: {entry.path}")
                log.info(f"Updated at {datetime.fromtimestamp(update_time).strftime('%Y-%m-%d %H:%M')}")
                return True
    return False

def scan_projects(last_scan_time: float) -> bool:
    project_registry = list_projects()
    for project in project_registry:
        if not os.path.exists(project['p1ProjectPath']):
            fetch_remote_projects()
            if not os.path.exists(project['p1ProjectPath']):
                log.warn(f"Project {project['projectId']} - path does not exist: {project['p1ProjectPath']}")
                continue
        project_dir = Path(project['p1ProjectPath']) # do we need to use Path here or can we just use os.scandir with the string path? --- IGNORE ---
        has_changed = scan_dir(project_dir, last_scan_time)
        if has_changed:
            return True
    return False


def detect_code_changes() -> None:
    '''
    Look for any changes in .json files, 
    or the addition or removal of .sh and ps1 files
    in the project directories or the built-in steps directory since the last scan. 
    If any changes are detected, rebuild the step registry.
    '''
    last_scan_file = f"{config['working_dir']}/context/global/last_step_scan.txt"
    parent_dir = os.path.dirname(last_scan_file)
    if not os.path.exists(parent_dir):
        os.makedirs(parent_dir, exist_ok=True)
    
    if not os.path.exists(last_scan_file):
        log.debug('No last scan file found, creating one')
        last_scan_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        with open(last_scan_file, 'w', encoding='utf-8') as file:
            file.write(str(last_scan_time))
        return
    
    with open(last_scan_file, 'r', encoding='utf-8') as file:
        raw_time_string = file.read().strip()

    last_scan_time = datetime.strptime(raw_time_string, '%Y-%m-%d %H:%M:%S').timestamp()

    core_changes = check_core(last_scan_time)
    lib_changes = check_libraries(last_scan_time)
    # if core_changes or lib_changes:
    #     run_smoke_tests()

    project_changes = scan_projects(last_scan_time)
    built_in_dir = Path(config['script_root'])
    built_in_changes = scan_dir(built_in_dir, last_scan_time)
    if project_changes or built_in_changes:
        scan_all_steps()

    last_scan_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    with open(last_scan_file, 'w', encoding='utf-8') as file:
        file.write(str(last_scan_time))
    