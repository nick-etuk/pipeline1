
import os
import pathlib
from pipeline1.registry.add_project.detect_python import detect_python_project, extract_description_python
from pipeline1.registry.get_registries import get_registries
from pipeline1.registry.write_registry import write_registry
from pipeline1.registry.update_step_registry import update_step_registry
from pipeline1.lib.logging import log

def add_project(path_param: str) -> None:
    # todo: where does project.json fit into this?
    # do we even need a project.json if we have the registry?

    detect_language = {
        'python': detect_python_project,
    }

    extract_description = {
        'python': extract_description_python,
    }

    languages = ['python']  # Extendable for other languages in the future


    project_path = path_param if path_param else os.getcwd()
    # current_path = str(pathlib.Path().resolve())

    prompts= {
        'project_id': {'prompt': 'Id', 'value': pathlib.Path(project_path).name},
        'title': {'prompt': 'Description', 'value': 'New project'},
        'sourceCodePath': {'prompt': 'Source code path', 'value': project_path},
    }

    for lang in languages:
        if detect_language[lang](project_path):
            log.info(f"Detected {lang} project at {project_path}")
            description = extract_description[lang](project_path)
            prompts['title']['value'] = description if description else prompts['title']['value']
            break

    # Prompt for project details. Skips prompts where the 'prompt' is 'none'. Uses the default value if the user just presses enter.
    new_project_entry = {}
    for key, default_item in prompts.items():
        if default_item['prompt'] == 'none':
            new_project_entry[key] = default_item['value']
            continue
        input_value = input(f"{default_item['prompt']} [{default_item['value']}]: ")
        new_project_entry[key] = input_value.strip() if input_value.strip() else default_item['value']

    new_project_entry['p1ProjectPath'] = project_path


    project_registry, _ = get_registries()

    # detect duplictate project_ids
    if any(x['project_id'] == new_project_entry['project_id'] for x in project_registry):
        log.info(f"Project {new_project_entry['project_id']} already exists in the registry.")
        return

    project_registry.append(new_project_entry)
    write_registry(project_registry, 'project')
    log.info(f"Added project {new_project_entry['title']} to registry.")

    update_step_registry(project_registry)
    return

