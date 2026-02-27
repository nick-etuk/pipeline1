from typing import Any
# from icecream import ic


def enrich_step(base_step: dict[str, Any], registry_entry: dict[str, Any]) -> dict[str, Any]:
    enriched_step = base_step.copy()
    enriched_step['step_id'] = base_step.get('id', registry_entry['base_filename'])

    registry_keys = registry_entry.keys()
    for key in registry_keys:
        if key not in enriched_step:
            enriched_step[key] = registry_entry[key]

    return enriched_step
