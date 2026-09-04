import os
import json
from typing import Any
from pipeline1.lib.variables_in_path_names import expand_path
from pipeline1.lib.context import get_context, set_context
from pipeline1.lib.logging import log
from pipeline1.run_step.enrich_step import enrich_step
from icecream import ic

def is_absolute_path(path: str) -> bool:
    return path == '/' or (len(path) >= 2 and path[1] == ':' and len(path) >= 2)


def set_step_exit_path(step: dict[str, Any], project_registry: list[dict[str, Any]]) -> None:  
    if 'exitTo' not in step:
        step['exitTo'] = step['path']
        log.debug(f"Using step path ({step['path']}) as exitTo")
        
    if is_absolute_path(step['exitTo']) and os.path.isdir(step['exitTo']):
        log.debug(f"Setting default step exit path to absolute path {step['exitTo']}")
        set_context('default_step_path', expand_path(step['exitTo']))
        return

    project_found = False
    for project in project_registry:
        if project['projectId'] == step['projectId']:
            project_found = True
            # project['source_code_path'] is the directory where the source code is located
            # project['p1ProjectPath'] is the directory where the project.json file is located.
            # The two are not always the same.
            project_root = project['source_code_path'] if 'source_code_path' in project else project['p1ProjectPath']
            exit_to_path = os.path.join(project_root, str(step['exitTo']))
            if not os.path.isdir(exit_to_path):
                log.warn(f"Path {exit_to_path} does not exist. Cannot set default step exit path.")
                return
            log.debug(f"Setting default step exit path to {exit_to_path}")
            set_context('default_step_path', expand_path(exit_to_path))
            break

    if not project_found:
        log.warn(f"Project id {step['projectId']} not found in project registry. Could not set default step exit path.")
        return
        
def set_default_step(project_registry: list[dict[str, Any]], step_registry_entry: dict[str, Any]) -> None:
    config_file = os.path.join(step_registry_entry['path'], f"{step_registry_entry['baseFilename']}.json")
    if not os.path.isfile(config_file):
        ic(step_registry_entry, config_file)
        log.warn(f"Cannot set default step to {step_registry_entry['stepId']} because it does not have a config file") 
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
