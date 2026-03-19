import json
import os
from typing import Any
from pipeline1.run_step.enrich_step import enrich_step
from pipeline1.run_step.execute_step import execute_step
from pipeline1.lib.logging import log

def run_step_by_id(step_id: str, step_args: list[str], step_registry: list[dict[str, Any]]) -> bool:
    found = False
    for step in step_registry:
        if step['stepId'] == step_id:
            found = True
            run_step(step_registry_entry=step, step_args=step_args, overrides=[], new_tab_active=False)
    if not found:
        log.warn(f"Step with id '{step_id}' not found in registry.")
    return found

def run_step(step_registry_entry: dict[str, Any], step_args: list[str], overrides: list[str], new_tab_active: bool = False) -> bool:
    base_step: dict[str, Any] = {}
    config_file = os.path.join(step_registry_entry['path'], f"{step_registry_entry['baseFilename']}.json")
    if os.path.exists(config_file):
        with open(config_file) as f:
            base_step = json.load(f)
    
    step = enrich_step(base_step, step_registry_entry)
    log.set_indent(0)
    return execute_step(step=step, args=step_args, overrides=overrides, new_tab_active=new_tab_active)