import csv
import json
import os
from typing import Any
from pipeline1.lib.config import config
from pipeline1.lib.logging import log
from pipeline1.run_step.enrich_step import enrich_step
from pipeline1.registry.update_step_registry import update_step_registry
from pipeline1.registry.get_registries import project_registry


def load_step(step_id: str) -> dict[str, Any]:
    step_registry_file = f"{config['working_dir']}/step_registry.csv"
    
    with open(step_registry_file) as f:
        reader = csv.DictReader(f)
        steps = [row for row in reader if (row['step_id'] == step_id or row['base_filename'] == step_id)]
        if not steps:
            log.warn(f"Step {step_id} not found in registry.")
            if input("Rescan step registry? (y/n): ").lower() == 'y':
                update_step_registry(project_registry=project_registry())
                f.seek(0)
                reader = csv.DictReader(f)
                steps = [row for row in reader if row['step_id'] == step_id]
            if not steps:
                log.error(f"Step {step_id} not found in registry")
        registry_entry = steps[0]
    
    base_step: dict[str, Any] = {}
    config_file = os.path.join(registry_entry['path'], f"{registry_entry['base_filename']}.json")
    if os.path.isfile(config_file):
        with open(config_file) as f:
            base_step = json.load(f)

    step = enrich_step(base_step=base_step, registry_entry=registry_entry)
    return step
