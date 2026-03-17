import json
from typing import Any
from pathlib import Path
from pipeline1.lib.logging import log


def sort_order(project_id: str) -> float:
    if project_id == 'core':
        return 20.0
    return 30.0

def make_step_title(step_id: str) -> str:
    return step_id.replace('_', ' ').capitalize()

def find_steps(project_id: str, project_path: str) -> list[dict[str, Any]] | None:
    # todo: find steps without config files, prevent duplicate step_ids across all projects
    step_dir = Path(project_path) / 'p1' / 'steps'
    if not step_dir.exists() or not step_dir.is_dir():
        step_dir = Path(project_path) / 'steps'
        if not step_dir.exists() or not step_dir.is_dir():
            print(f"Warning: No steps directory found in {project_path}")
            return None

    if step_dir == Path('conf/project_template'):
        log.debug(f"Skipping project template steps in {step_dir}")
        return None
    
    step_registry: list[dict[str, Any]] = []
    for step_config_file in step_dir.rglob('*.json'):
        if '__test' in str(step_config_file):
            continue
        with open(step_config_file, 'r') as f:
            content = f.read()
        try:
            step_config = json.loads(content)
        except json.JSONDecodeError:
            print(f"Warning: Could not parse JSON in {step_config_file}")
            continue

        base_filename = step_config_file.stem.lower().replace('-', '_')
        step_id = step_config.get('id', base_filename)
        menu = step_config.get('menu', '')
        title = step_config.get('title', make_step_title(step_id))
        my_sort_order = sort_order(project_id)
        if 'sortOrder' in step_config:
            my_sort_order = my_sort_order + step_config['sortOrder'] / 10
        
        step_registry.append({ 
            'step_id': step_id, 
            'project_id': project_id,
            'menu': menu,
            'title': title,
            'sort_order': my_sort_order,
            'base_filename': base_filename,
            'path': step_config_file.parent,
        })
    
    return step_registry
