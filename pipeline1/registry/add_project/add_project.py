
import os
import pathlib
import json
from pipeline1.registry.add_project.detect_python import detect_python_project, extract_description_python
from pipeline1.registry.add_project.list_projects import list_projects
from pipeline1.registry.steps.scan_project_steps import project_sort_order
from pipeline1.registry.write_registry import write_registry
from pipeline1.lib.logging import log


def add_project_registry_entry(new_project_entry: dict[str, str]) -> None:
    project_registry = list_projects()
    if any(x['projectId'] == new_project_entry['projectId'] for x in project_registry):
        log.info(f"Project {new_project_entry['projectId']} already exists in the registry.")
        return

    project_registry.append(new_project_entry)
    project_registry = sorted(project_registry, key=lambda x: float(x['sortOrder']))
    write_registry(project_registry, 'project')
    log.info(f"Added project {new_project_entry['title']} to registry.")


def add_project(path_param: str) -> None:
    detect_language = {
        'python': detect_python_project,
    }

    extract_description = {
        'python': extract_description_python,
    }

    languages = ['python']  # Extend to other languages in the future

    project_path = path_param if path_param else os.getcwd()

    project_json_path = pathlib.Path(project_path) / 'project.json'
    if project_json_path.exists():
        log.debug(f"Found project.json at {project_json_path}, using it to prefill project details.")
        with open(project_json_path, 'r', encoding='utf-8') as file:
            content = file.read()
        try:
            project_config = json.loads(content)
            project_id = project_config.get('projectId', pathlib.Path(project_path).name)
            new_project_entry = {
                'projectId': project_id,
                'title': project_config.get('title', 'New project'),
                'sortOrder': project_sort_order(project_id),
                'sourceCodePath': project_path,
                'p1ProjectPath': project_path
            }
            add_project_registry_entry(new_project_entry)
            return
        except json.JSONDecodeError:
            log.warn(f"Warning: Could not parse JSON in {project_json_path}")

    prompts= {
        'projectId': {'prompt': 'Id', 'value': pathlib.Path(project_path).name},
        'title': {'prompt': 'Description', 'value': 'New project'},
        'sourceCodePath': {'prompt': 'Source code path', 'value': project_path},
    }

    for lang in languages:
        if detect_language[lang](project_path):
            log.info(f"Detected {lang} project at {project_path}")
            description = extract_description[lang](project_path)
            prompts['title']['value'] = description if description else prompts['title']['value']
            break

    # Prompt for project details. Skip prompts where the 'prompt' is 'none'. 
    # Uses the default value if the user just presses enter.
    new_project_entry = {}
    for key, default_item in prompts.items():
        if default_item['prompt'] == 'none':
            new_project_entry[key] = default_item['value']
            continue
        input_value = input(f"{default_item['prompt']} [{default_item['value']}]: ")
        new_project_entry[key] = input_value.strip() if input_value.strip() else default_item['value']

    new_project_entry['p1ProjectPath'] = project_path
    new_project_entry['sortOrder'] = project_sort_order(new_project_entry['projectId'])

    add_project_registry_entry(new_project_entry)

