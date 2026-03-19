import os
import csv
from typing import Any
from pipeline1.lib.config import config
from pipeline1.registry.create_blank_registry import create_blank_registry
from pipeline1.lib.logging import log


def list_projects() -> list[dict[str, Any]]:
    registry_file = f"{config['working_dir']}/project_registry.csv"

    if not os.path.exists(registry_file):
        log.warn("Project registry not found in list_projects. Creating blank registry.")
        create_blank_registry('project')
        return []
    
    with open(registry_file, encoding='utf-8') as f:
        project_lines = f.readlines()
    registry = csv.DictReader(project_lines)
    project_registry = list(registry)
    project_registry = sorted(project_registry, key=lambda x: float(x['sortOrder']))
    return project_registry
