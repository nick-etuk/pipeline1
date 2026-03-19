import csv
import os
from typing import Any
from pipeline1.lib.config import config
from pipeline1.registry.add_project.list_projects import list_projects
from pipeline1.registry.create_blank_registry import create_blank_registry
from pipeline1.registry.remote_projects.fetch_remote_projects import fetch_remote_projects
from pipeline1.registry.steps.scan_all_steps import scan_all_steps
# from icecream import ic


def get_project_registry() -> list[dict[str, Any]]:
    registry_file = f"{config['working_dir']}/project_registry.csv"

    if not os.path.exists(registry_file):
        create_blank_registry('project')
        fetch_remote_projects()
        scan_all_steps()
    
    return list_projects()


def get_step_registry() -> list[dict[str, Any]]:
    registry_file = f"{config['working_dir']}/step_registry.csv"

    if not os.path.exists(registry_file):
        scan_all_steps()
    
    with open(registry_file, encoding='utf-8') as f:
        step_lines = f.readlines()
    registry = csv.DictReader(step_lines)
    registry = sorted(registry, key=lambda x: float(x['sortOrder']))
    return registry


def get_registries() -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    return get_project_registry(), get_step_registry()
