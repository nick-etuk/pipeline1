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
    
    with open(step_registry_file, encoding='utf-8') as registry_file:
        reader = csv.DictReader(registry_file)
        # steps = [row for row in reader if (row['stepId'] == step_id or row['baseFilename'] == step_id)]
        steps = [row for row in reader if step_id in (row['stepId'], row['baseFilename'])]
        if not steps:
            log.warn(f"Step {step_id} not found in registry.")
            # if input("Rescan step registry? (y/n): ").lower() == 'y':
            fetch_remote_projects()
            scan_all_steps()
            registry_file.seek(0)
            reader = csv.DictReader(registry_file)
            steps = [row for row in reader if step_id in (row['stepId'], row['baseFilename'])]
            if not steps:
                log.error(f"Step {step_id} not found in registry")
        registry_entry = steps[0]
    
    base_step: dict[str, Any] = {}
    config_file = os.path.join(registry_entry['path'], f"{registry_entry['baseFilename']}.json")
    if os.path.isfile(config_file):
        with open(config_file, encoding='utf-8') as registry_file:
            base_step = json.load(registry_file)

    step = enrich_step(base_step=base_step, registry_entry=registry_entry)
    return step
