from pipeline1.lib.logging import log
from pathlib import Path
from typing import Any

def sort_order(project_id: str) -> float:
    if project_id == 'core':
        return 20.0
    return 30.0

def make_step_title(step_id: str) -> str:
    return step_id.replace('_', ' ').capitalize()

def find_steps_without_config(project_id: str, project_path: str, existing_steps: list[dict[str, Any]]) -> list[dict[str, Any]]:
    step_dir = Path(project_path) / 'p1' / 'steps'
    if not step_dir.exists() or not step_dir.is_dir():
        step_dir = Path(project_path) / 'steps'
        if not step_dir.exists() or not step_dir.is_dir():
            print(f"Warning: No steps directory found in {project_path}")
            return None

    if step_dir == Path('conf/project_template'):
        log.debug(f"Skipping project template steps in {step_dir}")
        return
    
    new_steps: list[dict[str, Any]] = []
    included_extensions = ['.sh', '.ps1', '.py']
    for step_file in step_dir.rglob('*'):
        if step_file.suffix not in included_extensions:
            continue
        if '__test' in str(step_file):
            continue

        base_filename = step_file.stem.lower().replace('-', '_')
        if any(existing_step['path'] == step_file.parent and existing_step['base_filename'] == base_filename for existing_step in existing_steps):
            continue

        if any(new_step['path'] == step_file.parent and new_step['base_filename'] == base_filename for new_step in new_steps):
            continue

        step_id = base_filename
        my_sort_order = sort_order(project_id)
        log.warn(f"Warning: no config for  {step_file}")
        new_steps.append({ 
            'step_id': step_id, 
            'project_id': project_id, 
            'menu': '',
            'title': make_step_title(step_id),
            'sort_order': my_sort_order,
            'base_filename': base_filename,
            'path': step_file.parent,
        })
    
    return new_steps
