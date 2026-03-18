import csv
import os
from typing import Any
from pipeline1.lib.config import config
# from icecream import ic


def project_registry() -> list[dict[str, Any]]:
    registry_file = f"{config['working_dir']}/project_registry.csv"

    if not os.path.exists(registry_file):
        # todo: create registry file with headers
        # download remote projects
        # add remote projects to registry
        # update project registry
        # update step registry
        return []
    
    with open(registry_file, encoding='utf-8') as f:
        project_lines = f.readlines()
    registry = csv.DictReader(project_lines)
    registry = sorted(registry, key=lambda x: int(x['display_order']))
    return registry


def step_registry() -> list[dict[str, Any]]:
    registry_file = f"{config['working_dir']}/step_registry.csv"

    if not os.path.exists(registry_file):
        # todo: create registry file with headers
        # update step registry
        return []
    
    with open(registry_file, encoding='utf-8') as f:
        step_lines = f.readlines()
    registry = csv.DictReader(step_lines)
    registry = sorted(registry, key=lambda x: float(x['sort_order']))
    return registry

def get_registries() -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    return project_registry(), step_registry()
