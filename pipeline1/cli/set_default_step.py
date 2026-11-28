import os
import json
from typing import Any
from pathlib import PurePosixPath, PureWindowsPath
from pipeline1.lib.variables_in_path_names import expand_path
from pipeline1.lib.context import get_context, set_context
from pipeline1.lib.logging import log
from pipeline1.run_step.enrich_step import enrich_step
from icecream import ic


def is_absolute_path(path: str) -> bool:
    return PurePosixPath(path).is_absolute() or PureWindowsPath(path).is_absolute()


def resolve_project_root(project: dict[str, Any]) -> str:
    # project['sourceCodeRoot'] is the directory where the source code is located
    # In the past, this was named 'source_code_path'.
    # project['p1ProjectPath'] is the directory where the project.json file is located.
    # The two are not always the same. 'sourceCodeRoot' is preferred.
    
    if 'sourceCodeRoot' in project and project['sourceCodeRoot']:
        return project['sourceCodeRoot']

    if 'source_code_path' in project and project['source_code_path']:
        return project['source_code_path']

    if 'p1ProjectPath' in project and project['p1ProjectPath']:
        return project['p1ProjectPath']

    log.warn(f"Project root could not be determined for {project['projectId']}")
    return ""


def set_step_exit_path(step: dict[str, Any], project_registry: list[dict[str, Any]]) -> None:  
    if 'exitTo' not in step:
        exit_path = step['path']
        log.debug(f"No exit path defined for step {step['stepId']}")
        log.debug(f"Using step path ({exit_path}) as exit path")
        # step paths are absolute and do not contain environment variables
        set_context('default_step_path', exit_path)
        return

    exit_path = expand_path(step['exitTo'])
    if is_absolute_path(exit_path):
        if not os.path.isdir(exit_path):
            log.warn(f"Absolute exit path {exit_path} does not exist.")
            return
        log.debug(f"Setting default step exit path to absolute path {exit_path}")
        set_context('default_step_path', exit_path)
        return

    # Handle relative step['exitTo'] paths
    relative_path = exit_path

    project_found = False
    for project in project_registry:
        if project['projectId'] == step['projectId']:
            project_found = True

            project_root = resolve_project_root(project)
            if not project_root:
                return

            project_root = expand_path(project_root)
            if not os.path.isdir(project_root):
                log.warn(f"Project root path {project_root} does not exist. Cannot set default step exit path.")
                return

            exit_path = os.path.join(project_root, relative_path)
            if not os.path.isdir(exit_path):
                log.warn(f"Relative exit path {exit_path} does not exist. Cannot set default step exit path.")
                return
            log.debug(f"Setting default step exit path to {exit_path}")
            set_context('default_step_path', exit_path)
            break

    if not project_found:
        log.warn(f"Project id {step['projectId']} not found in project registry. Could not set default step exit path.")
        return
        
def set_default_step(project_registry: list[dict[str, Any]], step_registry_entry: dict[str, Any]) -> None:
    config_file = os.path.join(step_registry_entry['path'], f"{step_registry_entry['baseFilename']}.json")
    if not os.path.isfile(config_file):
        log.warn(f"Cannot set default step to {step_registry_entry['stepId']} because it does not have a config file") 
        ic(step_registry_entry, config_file)
        return
    
    with open(config_file, encoding="utf-8") as f:
        step = json.load(f)
        
    if not ('menu' in step and step['menu'] == 'main'): 
        return

    step = enrich_step(base_step=step, registry_entry=step_registry_entry)
    step_id = step['stepId']
    default_step_id = get_context('default_step_id')
    if default_step_id == step_id:
        return
    
    log.info(f"Setting default step id to {step_id}")
    set_context('default_step_id', step_id)

    set_step_exit_path(step, project_registry)
