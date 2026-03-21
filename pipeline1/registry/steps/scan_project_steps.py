import json
from typing import Any, Optional
from pathlib import Path
from pipeline1.lib.logging import log


def project_sort_order(project_id: str) -> float:
    # Output should be float not int. We divide the sort order by 10 in certain situations.
    # todo: add 10 to the max sort order in project registry
    if project_id == 'core':
        return 20.0
    return 30.0

def get_step_title(step_id: str) -> str:
    return step_id.replace('_', ' ').capitalize()

def scan_project_steps(project_id: str, project_path: str) -> Optional[list[dict[str, Any]]]:
    # todo: find steps without config files, prevent duplicate step_ids across all projects
    # step_dir = Path(project_path) / 'p1' / 'steps'
    step_dir = Path(project_path)
    if not step_dir.exists() or not step_dir.is_dir():
        log.warn(f"scan_project_steps: project path not found: {step_dir}")
        return None

    if step_dir == Path('conf/project_template'):
        log.debug(f"Skipping project template steps in {step_dir}")
        return None
    
    step_registry: list[dict[str, Any]] = []
    for step_config_file in step_dir.rglob('*.json'):
        if any(part in ['lib','shared'] for part in step_config_file.parts[:-1]):
            continue
        
        if '__test' in str(step_config_file):
            continue
        
        base_filename = step_config_file.stem.lower().replace('-', '_')
        if base_filename == 'project.json':
            continue

        with open(step_config_file, 'r') as f:
            content = f.read()
        try:
            step_config = json.loads(content)
        except json.JSONDecodeError:
            log.warn(f"Warning: Could not parse JSON in {step_config_file}")
            continue

        step_id = step_config.get('id', base_filename)
        menu = step_config.get('menu', '')
        title = step_config.get('title', get_step_title(step_id))
        my_sort_order = project_sort_order(project_id)
        if 'sortOrder' in step_config:
            my_sort_order = my_sort_order + step_config['sortOrder'] / 10
        
        step_registry.append({ 
            'stepId': step_id, 
            'projectId': project_id,
            'menu': menu,
            'title': title,
            'sortOrder': my_sort_order,
            'baseFilename': base_filename,
            'path': step_config_file.parent,
        })
    
    return step_registry
