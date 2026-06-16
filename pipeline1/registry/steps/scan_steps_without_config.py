from pipeline1.lib.logging import log
from pipeline1.registry.steps.scan_project_steps import project_sort_order, get_step_title
from pathlib import Path
from typing import Any, Optional


def scan_steps_without_config(project_id: str, project_path: str, existing_steps: list[dict[str, Any]]) -> Optional[list[dict[str, Any]]]:
    step_dir = Path(project_path) / 'p1' / 'steps'
    if not step_dir.exists() or not step_dir.is_dir():
        # step_dir = Path(project_path) / 'steps'
        step_dir = Path(project_path)
        if not step_dir.exists() or not step_dir.is_dir():
            log.warn(f"Warning: scan_steps_without_config - project path not found: {step_dir}")
            return None

    if step_dir == Path('conf/project_template'):
        log.debug(f"Skipping project template steps in {step_dir}")
        return None
    
    new_steps: list[dict[str, Any]] = []
    included_extensions = ['.sh', '.ps1', '.py']
    for step_file in step_dir.rglob('*'):
        if step_file.suffix not in included_extensions:
            continue
        if '__test' in str(step_file):
            continue

        base_filename = step_file.stem.lower().replace('-', '_')
        if any(existing_step['path'] == step_file.parent and existing_step['baseFilename'] == base_filename for existing_step in existing_steps):
            continue

        if any(new_step['path'] == step_file.parent and new_step['baseFilename'] == base_filename for new_step in new_steps):
            continue

        step_id = base_filename
        # log.warn(f"Warning: no config file for {step_file}")
        new_steps.append({ 
            'stepId': step_id, 
            'projectId': project_id, 
            'menu': '',
            'title': get_step_title(step_id),
            'sortOrder': project_sort_order(project_id),
            'baseFilename': base_filename,
            'path': step_file.parent,
        })
    
    return new_steps
