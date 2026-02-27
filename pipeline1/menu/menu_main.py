from typing import Any
from pipeline1.menu.get_project_menu_items import get_project_menu_items

def show_menu_main(project_registry: list[dict[str, Any]], step_registry: list[dict[str, Any]]) -> None :
    print("\n\t Welcome to Pipeline1\n\n")

    for project in project_registry:
        border = "-" * len(project['title'])
        print(f"\t {border}")
        print(f"\t {project['title']}")
        print(f"\t {border}")
        menu_items = get_project_menu_items(step_registry, project['project_id'])
        for step in menu_items:
            print(f"\t p1 {step['step_id']} \t {step['title']}")
        print("\n")
