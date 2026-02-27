from typing import Any


def get_project_menu_items(step_registry: list[dict[str, Any]], project_id: str) -> list[dict[str, Any]]:
    menu_items = [step for step in step_registry if step['project_id'] == project_id and step['menu'] == 'main']
    return menu_items