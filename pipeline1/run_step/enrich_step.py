from typing import Any


def enrich_step(base_step: dict[str, Any], registry_entry: dict[str, Any]) -> dict[str, Any]:
    '''
    Enriches the base step, i.e data read from the step's config.json,
    with additional information from the step registry.
    The registry entry may contain additional metadata about the step, such as its path, base filename, and other attributes.
    It gives precedence to the base step's attributes.
    '''
    enriched_step = base_step.copy()
    enriched_step['stepId'] = base_step.get('id', registry_entry['baseFilename'])

    registry_keys = registry_entry.keys()
    for key in registry_keys:
        if key not in enriched_step:
            enriched_step[key] = registry_entry[key]

    return enriched_step
