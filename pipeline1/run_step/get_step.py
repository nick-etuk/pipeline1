import csv
import json
import os
from typing import Any
from pipeline1.lib.config import config
from pipeline1.lib.logging import log
from pipeline1.registry.remote_projects.fetch_remote_projects import fetch_remote_projects
from pipeline1.run_step.enrich_step import enrich_step
from pipeline1.registry.steps.scan_all_steps import scan_all_steps

def get_step(step_id: str) -> dict[str, Any]:
    step_registry_file = f"{config['working_dir']}/step_registry.csv"

    def read_matching_steps() -> list[dict[str, str]]:
        with open(step_registry_file, encoding='utf-8') as registry_file:
            reader = csv.DictReader(registry_file)
            return [row for row in reader if step_id in (row['stepId'], row['baseFilename'])]

    if not os.path.isfile(step_registry_file):
        log.warn(f"Step registry file {step_registry_file} not found. Scanning all steps...")
        fetch_remote_projects()
        scan_all_steps()

        if not os.path.isfile(step_registry_file):
            log.warn(f"Step registry file {step_registry_file} still not found after scanning. Please check your configuration and try again.")
            return {}

    steps = read_matching_steps()
    
    if not steps:
        log.warn(f"Step {step_id} not found in registry. Re-scanning step registry...")
        fetch_remote_projects()
        scan_all_steps()
        steps = read_matching_steps()

        if not steps:
            log.warn(f"Step {step_id} still not found in registry after re-scanning. Please check the step ID and try again.")
            return {}
        
    registry_entry = steps[0]
    
    base_step: dict[str, Any] = {}
    config_file = os.path.join(registry_entry['path'], f"{registry_entry['baseFilename']}.json")
    if os.path.isfile(config_file):
        with open(config_file, encoding='utf-8') as registry_file:
            base_step = json.load(registry_file)
    # A step may not have a config file, in which case we just return the registry entry as the step.
    else:
        log.warn(f"Config file {config_file} not found for step {step_id}. Using registry entry as step.")
    step = enrich_step(base_step=base_step, registry_entry=registry_entry)
    return step
