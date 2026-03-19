import os
from pathlib import Path
import csv
from typing import Any
import difflib
from pipeline1.lib.config import config
from pipeline1.registry.add_project.list_projects import list_projects
from pipeline1.registry.create_blank_registry import create_blank_registry
# from pipeline1.registry.get_registries import get_project_registry
from pipeline1.registry.steps.scan_steps_without_config import scan_steps_without_config
from pipeline1.registry.steps.scan_project_steps import scan_project_steps
from pipeline1.lib.logging import log


def scan_all_steps() -> None:
    # pylint: disable=too-many-branches, too-many-statements
    log.info('Updating step registry')
    step_registry_file = f"{config['working_dir']}/step_registry.csv"

    backup_file = f"{step_registry_file}.bak"
    if Path(step_registry_file).exists():
        os.replace(step_registry_file, backup_file)
    else:
        create_blank_registry('step')

    combined_step_registry: list[dict[str, Any]] = []

    project_registry = list_projects()
    for project in project_registry:
        log.info(f"Scanning {project['projectId']} at {project['p1ProjectPath']}")
        if not os.path.exists(project['p1ProjectPath']):
            log.warn(f"Project {project['projectId']} - path does not exist: {project['p1ProjectPath']}")
            continue
        project_dir = Path(project['p1ProjectPath'])
        project_steps = scan_project_steps(project['projectId'], str(project_dir))
        if not project_steps:
            continue
        log.info(f"Found {len(project_steps)} steps in {project['projectId']}")
        combined_step_registry.extend(project_steps)
    
    built_in_steps = scan_project_steps('core', config['script_root'])
    if built_in_steps:
        log.info(f"Found {len(built_in_steps)} built-in steps")
        combined_step_registry.extend(built_in_steps)

    # Search for steps without a config file
    for project in project_registry:
        if not os.path.exists(project['p1ProjectPath']):
            log.warn(f"Project {project['projectId']} - path does not exist: {project['p1ProjectPath']}")
            continue
        project_dir = Path(project['p1ProjectPath'])
        steps_without_config = scan_steps_without_config(project_id=project['projectId'], project_path=str(project_dir), existing_steps=combined_step_registry)
        if not steps_without_config:
            continue
        combined_step_registry.extend(steps_without_config)

    combined_step_registry = sorted(combined_step_registry, key=lambda x: (x['sortOrder']))

    with open(step_registry_file, 'w', newline='') as csvfile:
        fieldnames = combined_step_registry[0].keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        for step in combined_step_registry:
            writer.writerow({
                'stepId': step['stepId'],
                'sortOrder': step['sortOrder'],
                'projectId': step['projectId'],
                'menu': step['menu'],
                'title': step['title'],
                'baseFilename': step['baseFilename'],
                'path': step['path']
            })

    if Path(step_registry_file).exists() and Path(backup_file).exists():
        with open(step_registry_file, 'r') as new_file, open(backup_file, 'r') as old_file:
            new_content = new_file.read()
            old_content = old_file.read()
            if new_content == old_content:
                log.info('Step registry unchanged.')
            else:
                log.info('Step registry updated.')
                diff = difflib.unified_diff(
                    old_content.splitlines(),
                    new_content.splitlines(),
                    fromfile='Previous',
                    tofile='New',
                    lineterm='')
                for line in diff:
                    print(line)
        os.remove(backup_file)
    else:
        log.info('Step registry created.')
