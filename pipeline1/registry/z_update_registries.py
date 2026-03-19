from typing import Any

from pipeline1.registry.steps.scan_all_steps import scan_all_steps

def z_update_registries(project_registry: list[dict[str, Any]]) -> None:
    # download remote projects
    # add remote projects to registry
    # update project registry
    scan_all_steps()