import os
from pathlib import Path
import csv
from typing import Any
import difflib
from pipeline1.lib.config import config
from pipeline1.lib.constants import FILE_HEADERS
from pipeline1.registry.add_project.list_projects import list_projects
# from pipeline1.registry.create_blank_registry import create_blank_registry
from pipeline1.registry.remote_projects.fetch_remote_projects import fetch_remote_projects
from pipeline1.registry.steps.scan_steps_without_config import scan_steps_without_config
from pipeline1.registry.steps.scan_project_steps import scan_project_steps
from pipeline1.lib.logging import log
from pipeline1.lib.variables_in_path_names import expand_path


def scan_all_steps() -> None:
    # pylint: disable=too-many-branches, too-many-statements
    log.info('Updating step registry')
    step_registry_file = f"{config['working_dir']}/step_registry.csv"

    old_content: str | None = None
    if Path(step_registry_file).exists():
        try:
            with open(step_registry_file, 'r', encoding='utf-8') as f:
                old_content = f.read()
        except OSError:
            log.warn(f"Could not read existing {step_registry_file}")

    combined_step_registry: list[dict[str, Any]] = []

    project_registry = list_projects()
    for project in project_registry:
        # project_path = decode_variables_in_path(project['p1ProjectPath'])
        project_path = expand_path(project['p1ProjectPath'])
        log.info(f"Scanning {project['projectId']} at {project_path}")
        if not os.path.exists(project_path):
            fetch_remote_projects()
            if not os.path.exists(project_path):
                log.warn(f"Scan_all_steps: project {project['projectId']} - path does not exist: {project_path}")
                continue
        project_dir = Path(project_path)
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
        project_path = expand_path(project['p1ProjectPath'])
        if not os.path.exists(project_path):
            fetch_remote_projects()
            if not os.path.exists(project_path):
                log.warn(f"Scan_all_steps_2: project {project['projectId']} - path does not exist: {project_path}")
                continue
        project_dir = Path(project_path)
        steps_without_config = scan_steps_without_config(project_id=project['projectId'], project_path=str(project_dir), existing_steps=combined_step_registry)
        if not steps_without_config:
            continue
        combined_step_registry.extend(steps_without_config)

    combined_step_registry = sorted(combined_step_registry, key=lambda x: (x['sortOrder']))

    fieldnames = list(combined_step_registry[0].keys()) if combined_step_registry else FILE_HEADERS['step']
    with open(step_registry_file, 'w', newline='', encoding='utf-8') as csvfile:
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

    if old_content is not None:
        with open(step_registry_file, 'r', encoding='utf-8') as new_file:
            new_content = new_file.read()
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
    else:
        log.info('Step registry created.')
