from typing import Any
# from icecream import ic


def enrich_step(base_step: dict[str, Any], registry_entry: dict[str, Any]) -> dict[str, Any]:
    enriched_step = base_step.copy()
    enriched_step['stepId'] = base_step.get('id', registry_entry['baseFilename'])

    registry_keys = registry_entry.keys()
    for key in registry_keys:
        if key not in enriched_step:
            enriched_step[key] = registry_entry[key]

    return enriched_step
