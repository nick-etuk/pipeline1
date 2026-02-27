import os
from pathlib import Path
import csv
from typing import Any
import difflib
from pipeline1.lib.config import config
from pipeline1.registry.find_steps_without_config import find_steps_without_config
from pipeline1.registry.find_steps import find_steps
from pipeline1.lib.logging import log

def update_step_registry(project_registry: list[dict[str, Any]]) -> None:
    log.info('Updating step registry')
    step_registry_file = f"{config['working_dir']}/step_registry.csv"

    backup_file = f"{step_registry_file}.bak"
    if Path(step_registry_file).exists():
        os.replace(step_registry_file, backup_file)

    combined_step_registry: list[dict[str, Any]] = []
    for project in project_registry:
        log.info(f"Scanning {project['project_id']} at {project['p1_project_path']}")
        if not os.path.exists(project['p1_project_path']):
            log.warn(f"Project {project['project_id']} - path does not exist: {project['p1_project_path']}")
            continue
        project_dir = Path(project['p1_project_path'])
        project_steps = find_steps(project['project_id'], str(project_dir))
        if not project_steps:
            continue
        log.info(f"Found {len(project_steps)} steps in {project['project_id']}")
        combined_step_registry.extend(project_steps)
    
    core_steps = find_steps('core', config['script_root'])
    if core_steps:
        log.info(f"Found {len(core_steps)} steps in core")
        combined_step_registry.extend(core_steps)

    for project in project_registry:
        if not os.path.exists(project['p1_project_path']):
            log.warn(f"Project {project['project_id']} - path does not exist: {project['p1_project_path']}")
            continue
        project_dir = Path(project['p1_project_path'])
        steps_without_config = find_steps_without_config(project_id=project['project_id'], project_path=str(project_dir), existing_steps=combined_step_registry)
        if not steps_without_config:
            continue
        combined_step_registry.extend(steps_without_config)

    combined_step_registry = sorted(combined_step_registry, key=lambda x: (x['sort_order']))

    with open(step_registry_file, 'w', newline='') as csvfile:
        fieldnames = combined_step_registry[0].keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        for step in combined_step_registry:
            writer.writerow({
                'step_id': step['step_id'],
                'sort_order': step['sort_order'],
                'project_id': step['project_id'],
                'menu': step['menu'],
                'title': step['title'],
                'base_filename': step['base_filename'],
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
