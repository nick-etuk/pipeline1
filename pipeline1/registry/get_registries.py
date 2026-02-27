import csv
import os
from typing import Any
from pipeline1.lib.config import config
# from icecream import ic


def project_registry() -> list[dict[str, Any]]:
    project_file = f"{config['working_dir']}/project_registry.csv"

    if not os.path.exists(project_file):
        return []
    
    with open(project_file) as f:
        project_lines = f.readlines()
    project_registry = csv.DictReader(project_lines)
    project_registry = sorted(project_registry, key=lambda x: int(x['display_order']))
    return project_registry

def activity_registry() -> list[dict[str, Any]]:
    activity_file = f"{config['working_dir']}/activity_registry.csv"

    if not os.path.exists(activity_file):
        return []
    
    with open(activity_file) as f:
        activity_lines = f.readlines()
    activity_registry = csv.DictReader(activity_lines)
    activity_registry = sorted(activity_registry, key=lambda x: int(x['display_order']))
    return activity_registry

def step_registry() -> list[dict[str, Any]]:
    step_file = f"{config['working_dir']}/step_registry.csv"

    if not os.path.exists(step_file):
        return []
    
    with open(step_file) as f:
        step_lines = f.readlines()
    step_registry = csv.DictReader(step_lines)
    step_registry = sorted(step_registry, key=lambda x: float(x['sort_order']))
    return step_registry

def get_registries() -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    return project_registry(), step_registry()
